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

@implementation MapViewController {
    GMSMapView *mapView_;
}

@synthesize eventTypeInput;
@synthesize eventTypeInput1;
@synthesize eventList;
@synthesize locationManager;
@synthesize locationList;

- (void)viewDidLoad {
    ///////////////////
    ///////////////////
    [super viewDidLoad];

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
    for(id events in eventList){
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
    NSLog(@"%lu", (unsigned long)[locationList count]);
    for(id location in locationList){
        NSLog(@"I'm walking on sunshine");
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake([location[@"latitude"] floatValue], [location[@"longitude"] floatValue]);
        NSString *destinationName=location[@"name"];
        marker.title = destinationName;
        marker.map = mapView_;
    }
}

- (void) getDataAndDisplayMap:(NSString*)defaultTerm defaultLocation:(NSString*)defaultLocation cll:(NSString*)cll{
    // Get the term from form input in DataViewController
    // defaultTerm = self.eventTypeInput;
    // the string from the other view is eventTypeInput
    if(eventTypeInput)
      [eventList addObject:@{
          @"name":@"addedone",
          @"type":eventTypeInput}
      ];

    //Get the term and location from the command line if there were any, otherwise assign default values.
    NSString *term = [[NSUserDefaults standardUserDefaults] valueForKey:@"term"] ?: defaultTerm;
    NSString *location = [[NSUserDefaults standardUserDefaults] valueForKey:@"location"] ?: defaultLocation;
   
    YPAPISample *APISample = [[YPAPISample alloc] init];
   
    dispatch_group_t requestGroup = dispatch_group_create();
   
    dispatch_group_enter(requestGroup);
    [APISample queryTopBusinessInfoForTerm:term location:location cll:cll completionHandler:^(NSDictionary *topBusinessJSON, NSError *error) {
   
        if (error) {
            NSLog(@"An error happened during the request: %@", error);
        } else if (topBusinessJSON) {
            //NSLog(@"Top business info: \n %@", topBusinessJSON);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* locations = topBusinessJSON[@"location"];
                NSNumber *latitude = locations[@"coordinate"][@"latitude"];
                NSNumber *longitutde = locations[@"coordinate"][@"longitude"];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue]
                                                                        longitude:[longitutde floatValue]
                                                                             zoom:15];
                mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
                mapView_.mapType = kGMSTypeNormal;
                mapView_.myLocationEnabled = YES;
                self.view = mapView_;
   
                // Creates a marker in the center of the map.
                GMSMarker *marker = [[GMSMarker alloc] init];
                marker.position = CLLocationCoordinate2DMake([latitude floatValue], [longitutde floatValue]);
                NSString *destinationName=topBusinessJSON[@"name"];
                marker.title = destinationName;
                marker.snippet = locations[@"city"];
                marker.map = mapView_;
                
            });
        } else {
            NSLog(@"No business was found");
        }
   
        dispatch_group_leave(requestGroup);
    }];
   
    dispatch_group_wait(requestGroup, DISPATCH_TIME_FOREVER); // This avoids the program exiting before all our asynchronous callbacks have been made.

    ///////////////////
    ///////////////////
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showForm"]){
      DataViewController *controller = (DataViewController *)segue.destinationViewController;
      controller.eventType = eventTypeInput;
        controller.eventType1 = eventTypeInput1;
      controller.eventList = eventList;
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
    NSLog(@"Cll is %@", cll);
    //[self getDataAndDisplayMap:self.eventTypeInput defaultLocation:@"New York, NY" cll:cll];
    [self getData:@"New York, NY" cll:cll];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self mapData:cll];
    });
}
@end
