//
//  DataViewController.m
//  RoutePro
//
//  Created by Sara Linsley on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "DataViewController.h"
#import "MapViewController.h"


@implementation DataViewController

@synthesize eventType;
@synthesize eventType1;
@synthesize eventList;

- (void)viewDidLoad {
    [super viewDidLoad];
    if(!eventList){
        eventList = [[NSMutableArray alloc] init];
              [eventList addObject:
                @{@"name": @"Eataly",
                  @"type": @"food"}];
              [eventList addObject:
                @{@"name": @"MoMa",
                  @"type": @"museum"}
              ];
    };
    NSLog(@"eventType: %@",eventType);
    NSMutableString *displayEventList = [[NSMutableString alloc] init];
    NSString *temp = [[NSString alloc] init];
    for(int i=0;i<[eventList count]; i++){
        temp = [NSString stringWithFormat:@"eventList[%d] = %@,%@\n",i,[eventList[i] objectForKey:@"name"],[eventList[i] objectForKey:@"type"]];
        [displayEventList appendString:temp];
    }


    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIEdgeInsets insets = {0, 50, 0, 50};
    for(int i=0;i<[eventList count];i++){
        UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(10, 100+(i*50), 200, 40)];
        [newEvent setLayoutMargins:insets];
        [newEvent setTextColor:white];
        [newEvent setBackgroundColor:turquoise];
        [newEvent setText:[[eventList objectAtIndex:i] objectForKey:@"name"]];
        [self.scrollView addSubview:newEvent];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)addEventPressed:(UIButton*)sender{
    eventType = self.eventTypeField.text;
    eventType1 = self.eventTypeField1.text;
//    [eventList addObject:
//     @{@"name": @"MoMa",
//       @"type": eventType}
//     ];
//    [eventList addObject:
//     @{@"name": @"MoMa",
//       @"type": eventType1}
//     ];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showMap"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.eventTypeInput = eventType;
        controller.eventTypeInput1 = eventType1;
        controller.eventList = eventList;
    }
}
@end
