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
@property (weak, nonatomic) IBOutlet UITextField *eventTypeField1;
@property (strong, nonatomic) NSString *eventType;
@property (strong, nonatomic) NSString *eventType1;
@property (strong, nonatomic) NSMutableArray *eventList;
@property (strong, nonatomic) IBOutlet UITableViewCell *eventCell;
@property (strong, nonatomic) IBOutlet UITableView *eventListTable;
@property (strong, nonatomic) IBOutlet UITextView *testText;

@end
