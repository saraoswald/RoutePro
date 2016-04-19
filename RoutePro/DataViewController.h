//
//  DataViewController.h
//  RoutePro
//
//  Created by Sara Linsley on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DataViewController : UIViewController

@property (strong, nonatomic) IBOutlet UILabel *dataLabel;
@property (strong, nonatomic) id dataObject;
@property (strong, nonatomic) IBOutlet UIButton *addEvent;
@property (strong, nonatomic) IBOutlet UITableView *eventList;

@end

