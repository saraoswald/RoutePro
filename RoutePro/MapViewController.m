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
@import GoogleMaps;

@implementation MapViewController {
    GMSMapView *mapView_;
}

- (void)viewDidLoad {
    ///////////////////
    ///////////////////
    [super viewDidLoad];
    NSString *defaultTerm = @"food";
    NSString *defaultLocation = @"New York, NY";
    
    //Get the term and location from the command line if there were any, otherwise assign default values.
    NSString *term = [[NSUserDefaults standardUserDefaults] valueForKey:@"term"] ?: defaultTerm;
    NSString *location = [[NSUserDefaults standardUserDefaults] valueForKey:@"location"] ?: defaultLocation;
    
    YPAPISample *APISample = [[YPAPISample alloc] init];
    
    dispatch_group_t requestGroup = dispatch_group_create();
    
    dispatch_group_enter(requestGroup);
    [APISample queryTopBusinessInfoForTerm:term location:location completionHandler:^(NSDictionary *topBusinessJSON, NSError *error) {
        
        if (error) {
            NSLog(@"An error happened during the request: %@", error);
        } else if (topBusinessJSON) {
            NSLog(@"Top business info: \n %@", topBusinessJSON);
            dispatch_async(dispatch_get_main_queue(), ^{
                NSDictionary* locations = topBusinessJSON[@"location"];
                NSNumber *latitude = locations[@"coordinate"][@"latitude"];
                NSNumber *longitutde = locations[@"coordinate"][@"longitude"];
                GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:[latitude floatValue]
                                                                        longitude:[longitutde floatValue]
                                                                             zoom:10];
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

@end