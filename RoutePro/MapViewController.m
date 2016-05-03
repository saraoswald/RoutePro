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
@import GoogleMaps;

static NSString * const kAPIHost           = @"maps.googleapis.com/maps/api/directions";
static NSString * const kAPIPath           = @"/json";
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

- (void)viewDidLoad {
    ///////////////////
    ///////////////////
    [super viewDidLoad];
    colorList = [[NSMutableArray alloc] init];
    [colorList addObject:[UIColor redColor]];
    [colorList addObject:[UIColor blueColor]];
    [colorList addObject:[UIColor greenColor]];
    [colorList addObject:[UIColor blackColor]];
    [colorList addObject:[UIColor yellowColor]];
//    NSString *defaultTerm = self.eventTypeInput;
//    NSString *defaultLocation = @"New York, NY";
    locationList = [[NSMutableArray alloc] init];
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
//(NSMutableArray*)eventList defaultLocation:
- (void) getData: (NSString*)defaultLocation cll:(NSString*)cll{
    dispatch_group_t requestGroup = dispatch_group_create();
    for(int i=0; i<[eventList count]; i++){
        NSDictionary *events = eventList[i];
        //Get the term and location from the command line if there were any, otherwise assign default values.
        NSString *term = events[@"type"];
        NSString *location = defaultLocation;
        
        YPAPISample *APISample = [[YPAPISample alloc] init];
        
//        dispatch_group_t requestGroup = dispatch_group_create();
        
        dispatch_group_enter(requestGroup);
        [APISample queryTopBusinessInfoForTerm:term location:location cll:cll completionHandler:^(NSDictionary *topBusinessJSON, NSError *error) {
            
            if (error) {
                NSLog(@"An error happened during the request: %@", error);
            }
            
            else if (topBusinessJSON) {
                NSDictionary* locations = topBusinessJSON[@"location"];
                NSNumber *latitude = locations[@"coordinate"][@"latitude"];
                NSNumber *longitutde = locations[@"coordinate"][@"longitude"];
                
                [locationList addObject:@{
                    @"name":topBusinessJSON[@"name"],
                    @"userInput":term,
                    @"latitude":latitude,
                    @"longitude":longitutde}];
            }
        dispatch_group_leave(requestGroup);
        }];
    }
    dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER);
}
//to be called after getData
- (void) mapData: (NSString*)cll{
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
//    NSLog(@"The length of location list at time of pinning %lu", (unsigned long)[locationList count]);
    NSString *startLoc = cll;
    NSString *destLoc = [[NSString alloc] init];
    int colorCode = 0;
    for(int i=0; i<[eventList count]; i++){
        //make sure that we get directions in order
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", eventList[i][@"type"]];
        NSArray *filteredArray = [locationList filteredArrayUsingPredicate:predicate];
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
//    NSString *testDestination = [NSString stringWithFormat:@"%@,%@",locationList[0][@"latitude"],locationList[0][@"longitude"]];
//    NSString *testDestination = [NSString stringWithFormat:@"%@,%@",@"40.7617",@"-73.9819"];
    
//    locationList[0][@"latitude"]+@","+locationList[0][@"longitude"];
//    [self getDirectionsBetween2Points:cll destinationCoordinates:testDestination];
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIButton *newEvent = [[UIButton alloc] initWithFrame:CGRectMake(10, 20, 50, 50)];
    [newEvent setBackgroundColor:turquoise];
    //    [newEvent setTitle:@"back" forState:UIControlStateNormal];
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
//    NSLog(@"Got directions between %@, %@", startCoordinates, destinationCoordinates);
    kOriginCoor = startCoordinates;
    kDestinationCoor = destinationCoordinates;
    NSDictionary *params = @{
                             //                             @"key": kAPIKey,
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
            
            
            
            //            } else {
            //                NSLog(@"Not enough lines");
            //                //completionHandler(nil, error); // No business was found
            //            }
        } else {
            NSLog(@"error");
            //completionHandler(nil, error); // An error happened or the HTTP response is not a 200 OK
        }
    }] resume];
    
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    //TODO: The length of eventList is as expected. After two rounds unexpected length for location list. Fix this.
    
    if([segue.identifier isEqualToString:@"showForm"]){
        DataViewController *controller = (DataViewController *)segue.destinationViewController;
//        NSLog(@"length of eventlist on segue: %lu",(unsigned long)[eventList count]);
        controller.eventType = eventTypeInput;
        NSMutableArray *returnList = [[NSMutableArray alloc] init];
        for(int i=0; i<[eventList count]; i++){
            NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", eventList[i][@"type"]];
            NSArray *filteredArray = [locationList filteredArrayUsingPredicate:predicate];
            NSDictionary *location = filteredArray[0];
            [returnList insertObject:@{@"name":location[@"name"],
                                       @"type":location[@"userInput"]} atIndex:i];
        }
        controller.eventList =  returnList;
//        NSLog(@"REMOVING ALL OBJECTS IN MAP VIEW");
        [locationList removeAllObjects];
        [eventList removeAllObjects];
//        NSLog(@"%lu", (unsigned long)[locationList count]);
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
//    NSLog(@"Cll is %@", cll);
    //[self getDataAndDisplayMap:self.eventTypeInput defaultLocation:@"New York, NY" cll:cll];
    [self getData:@"New York, NY" cll:cll];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mapData:cll];
    });
}
@end
