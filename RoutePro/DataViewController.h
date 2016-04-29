//
//  DataViewController.h
//  RoutePro
//
//  Created by Sara Linsley on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapViewController.h"

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;
@property (strong, nonatomic) IBOutlet UIButton *addEvent;
@property (strong, nonatomic) IBOutlet UITextField *eventTypeField;
@property (strong, nonatomic) NSString *eventType;
//@property (strong, nonatomic) IBOutlet UITableView *eventList;

-(NSString*) getEventType;

@end
