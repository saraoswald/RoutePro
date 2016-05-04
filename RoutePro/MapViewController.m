//
//  MapViewController.m
//  RoutePro
//
//  Created by Sahil Pal on 4/25/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import <Foundation/Foundation.h>
#import "YPAPISample.h"
#import "MapViewController.h"
#import "DataViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "SharedBusinessInfo.h"
@import GoogleMaps;

static NSString * const kAPIHost           = @"maps.googleapis.com/maps/api/";
static NSString * const kAPIPath           = @"directions/json";
static NSString * const kAPIPath2          = @"distancematrix/json";
static NSString * kOriginCoor              = @"";
static NSString * kDestinationCoor         = @"";
static NSString * const kAPIKey            = @"AIzaSyA0SZqFvrE8niKTfOrQsH42NznqqG6Fpgs";

@implementation MapViewController {
    GMSMapView *mapView_;
}

@synthesize eventTypeInput;
@synthesize eventTypeInput1;
@synthesize eventList;
@synthesize locationManager;
@synthesize locationList;
@synthesize colorList;

//TODO: Implement protocol for cases where Yelp API returns no results

- (void)viewDidLoad {
    ///////////////////
    ///////////////////
    [super viewDidLoad];
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    [[allInfo locationList] removeAllObjects];
    
    colorList = [[NSMutableArray alloc] init];
    [colorList addObject:[UIColor redColor]];
    [colorList addObject:[UIColor blueColor]];
    [colorList addObject:[UIColor greenColor]];
    [colorList addObject:[UIColor blackColor]];
    [colorList addObject:[UIColor yellowColor]];
    
    //SETFORREMOVAL
//    locationList = [[NSMutableArray alloc] init];
    ////////////start up corelocation to find user location
    if([CLLocationManager locationServicesEnabled]){
        locationManager = [[CLLocationManager alloc] init];
        [locationManager requestWhenInUseAuthorization];
        
        locationManager.delegate = self;
        locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // Set a movement threshold for new events.
        locationManager.distanceFilter = kCLDistanceFilterNone; // meters
        
        //check startUpdatingLocation callback to see calls to getDataAndDisplayMap
        [locationManager startUpdatingLocation];
    }
    /////////////
    
    
}

- (void) getData: (NSString*)defaultLocation cll:(NSString*)cll{
    dispatch_group_t requestGroup = dispatch_group_create();
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
//    for(int i=0; i<[[allInfo eventList] count]; i++){
    for(int i=0; i<[allInfo size]; i++){
        NSDictionary *events = [allInfo userInputs][i];
        NSString *term = events[@"type"];
        NSString *location = defaultLocation;
        
        YPAPISample *APISample = [[YPAPISample alloc] init];
        
        dispatch_group_enter(requestGroup);
        
        //this completion handler definition used multiple times throughout Yelp API calls
        [APISample queryTopBusinessInfoForTerm:term location:location cll:cll completionHandler:^(NSDictionary *topBusinessJSON, NSError *error) {
            
            if (error) {
                NSLog(@"An error happened during the request: %@", error);
            }
            
            else if (topBusinessJSON) {
                NSDictionary* locations = topBusinessJSON[@"location"];
                NSNumber *latitude = locations[@"coordinate"][@"latitude"];
                NSNumber *longitutde = locations[@"coordinate"][@"longitude"];
                if([[allInfo locationList] containsObject:@{
                                                            @"name":topBusinessJSON[@"name"],
                                                            @"userInput":term,
                                                            @"latitude":latitude,
                                                            @"longitude":longitutde}]){
                }
                else{
                    [[allInfo locationList] addObject:@{
                        @"name":topBusinessJSON[@"name"],
                        @"userInput":term,
                        @"latitude":latitude,
                        @"longitude":longitutde}];
                }
            }
        dispatch_group_leave(requestGroup);
        }];
    }
    dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER);
}


//to be called after getData, must be in main thread
- (void) mapData: (NSString*)cll{
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    //centers map on user location
    NSArray* userLoc = [cll componentsSeparatedByString:@","];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[userLoc[0] floatValue]
                                                            longitude:[userLoc[1] floatValue]
                                                                 zoom:15];
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.mapType = kGMSTypeNormal;
    mapView_.myLocationEnabled = YES;
    self.view = mapView_;
    
    //pins all locations in locationList
    NSString *startLoc = cll;
    NSString *destLoc = [[NSString alloc] init];
    int colorCode = 0;
    for(int i=0; i<[[allInfo locationList] count]; i++){
        NSLog(@"Mapping an item with index %d", i);
        //make sure that we get directions in order
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", [allInfo userInputs][i][@"type"]];
        NSArray *filteredArray = [[allInfo locationList] filteredArrayUsingPredicate:predicate];
        NSDictionary *location = filteredArray[0];
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([location[@"latitude"] floatValue], [location[@"longitude"] floatValue]);
        NSString *destinationName=location[@"name"];
        marker.title = destinationName;
        marker.snippet = location[@"userInput"];
        marker.map = mapView_;
        destLoc = [NSString stringWithFormat:@"%f,%f",[location[@"latitude"] floatValue],[location[@"longitude"] floatValue]];
        [self getDirectionsBetween2Points:startLoc destinationCoordinates:destLoc colorCode:colorCode];
        startLoc = destLoc;
        colorCode++;
    }
    
    //create button to return to DVC
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIButton *newEvent = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 50, 50)];
    [newEvent setBackgroundColor:turquoise];
    newEvent.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"listicon"]];
    [newEvent addTarget:self
                 action:@selector(buttonClicked)
       forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:newEvent];
}

-(void) buttonClicked{
    [self performSegueWithIdentifier:@"showForm" sender:self];
}

- (void) getDirectionsBetween2Points: (NSString*) startCoordinates destinationCoordinates: (NSString*)destinationCoordinates colorCode: (int) colorCode{
    colorCode = colorCode % [colorList count];
    kOriginCoor = startCoordinates;
    kDestinationCoor = destinationCoordinates;
    NSDictionary *params = @{
                             @"destination": destinationCoordinates,
                             @"origin": startCoordinates
                             };
    
    NSURLRequest *directionRequest = [NSURLRequest requestWithHost:kAPIHost path:kAPIPath params:params];
    //    NSString *requestPath = [[directionRequest URL] absoluteString];
    NSURLSession *session = [NSURLSession sharedSession];
    [[session dataTaskWithRequest:directionRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        
        if (!error && httpResponse.statusCode == 200) {
            NSDictionary *searchResponseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSMutableArray *routes =searchResponseJSON[@"routes"];
                NSDictionary *firstRoute = routes[0];
                NSString *polyLineEncoded = firstRoute[@"overview_polyline"][@"points"];
                GMSPolyline *polyPath = [GMSPolyline polylineWithPath:[GMSPath pathFromEncodedPath:polyLineEncoded]];
                polyPath.strokeColor        = colorList[colorCode];
                polyPath.strokeWidth        = 3.5f;
                polyPath.map                = mapView_;
            });

        } else {
            NSLog(@"error");
            //completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
        }
    }] resume];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //TODO: The length of eventList is as expected. After two rounds unexpected length for location list. Fix this.
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
//    [[allInfo eventList] removeAllObjects];
    
    //TODO: Probably need to make YPAPI calls in DVC otherwise can't get business names and stuff without first visiting MVC
    
    if([segue.identifier isEqualToString:@"showForm"]){
        DataViewController *controller = (DataViewController *)segue.destinationViewController;
        controller.eventType = eventTypeInput;
        
        
        //TODO: Find out why this crashes after multiple cycles
        
//        for(int i=0; i<[[allInfo locationList] count]; i++){
        for(int i=0; i<[allInfo size]; i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", [allInfo locationList][i][@"userInput"]];
            NSArray *filteredArray = [[allInfo locationList] filteredArrayUsingPredicate:predicate];
            NSDictionary *location = filteredArray[0];
            if([[allInfo eventList] containsObject:@{@"name":location[@"name"],
                                                     @"type":location[@"userInput"]}]==NO){
                [[allInfo eventList] addObject:@{@"name":location[@"name"],
                                           @"type":location[@"userInput"]}];
            }
        }
        controller.eventList =  [allInfo eventList];
//        [locationList removeAllObjects];
//        [eventList removeAllObjects];
    }
  };


// Method to return user coordinates
- (NSString *)deviceLocation
{
    NSString *theLocation = [NSString stringWithFormat:@"latitude: %f longitude: %f", self.locationManager.location.coordinate.latitude, self.locationManager.location.coordinate.longitude];
    return theLocation;
}

// Delegate method from the CLLocationManagerDelegate protocol.
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"didFailWithError: %@", error);
    UIAlertController *errorAlert = [UIAlertController alertControllerWithTitle:@"Critical error" message:@"Couldn't find your location" preferredStyle:UIAlertControllerStyleAlert];
    [self presentViewController:errorAlert animated:NO completion:nil];
}

- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        // If the event is recent, do something with it.
        NSLog(@"latitude %+.6f, longitude %+.6f\n",	
              location.coordinate.latitude,
              location.coordinate.longitude);
    }
    [locationManager stopUpdatingLocation];
    
    NSString* cll=[NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    [self getData:@"New York, NY" cll:cll];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mapData:cll];
    });
}
@end
