//
//  MapViewController.h
//  RoutePro
//
//  Created by Sahil Pal on 4/25/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MapViewController : UIViewController

@property(nonatomic) NSString *eventTypeInput;
@property(strong,nonatomic) IBOutlet UILabel *label;

-(void) setEventTypeInput:(NSString *)eventType;

@end
