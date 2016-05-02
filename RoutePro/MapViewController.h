//
//  MapViewController.h
//  RoutePro
//
//  Created by Sahil Pal on 4/25/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface MapViewController : UIViewController <CLLocationManagerDelegate>


@property (nonatomic,retain) CLLocationManager *locationManager;
@property(nonatomic) NSString *eventTypeInput;
@property(nonatomic) NSString *eventTypeInput1;
@property(strong,nonatomic) IBOutlet UILabel *label;
@property (strong, nonatomic) NSMutableArray *eventList;
@property (strong, nonatomic) NSMutableArray *locationList;

@end
