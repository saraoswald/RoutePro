//
//  DataViewController.m
//  RoutePro
//
//  Created by Sara Linsley on 4/13/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "DataViewController.h"
#import "MapViewController.h"
#import "SharedBusinessInfo.h"

@implementation DataViewController

@synthesize eventType;
@synthesize eventList;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //singleton testing
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    //SETFORREMOVAL
    if(!eventList){
        eventList = [[NSMutableArray alloc] init];
    }
    NSMutableString *displayEventList = [[NSMutableString alloc] init];
    NSString *temp = [[NSString alloc] init];
//    for(int i=0;i<[[allInfo eventList] count]; i++){
    for(int i=0;i<[allInfo size]; i++){
        temp = [NSString stringWithFormat:@"eventList[%d] = %@,%@\n",i,[[allInfo eventList][i] objectForKey:@"name"],[[allInfo eventList][i] objectForKey:@"type"]];
        [displayEventList appendString:temp];
    }
    
    
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    UIEdgeInsets insets = {0, 50, 0, 50};
    int leftmargin = 50;
    int width = 300;
//    for(int i=0;i<[[allInfo locationList] count];i++){
    for(int i=0;i<[allInfo size];i++){
        UILabel *newTransit = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, (i*140)+10, width, 30)];
        [newTransit setLayoutMargins:insets];
        [newTransit setTextColor:turquoise];
        [newTransit setBackgroundColor:white];
        [newTransit setFont:[UIFont systemFontOfSize:12]];
        [newTransit setTextAlignment:NSTextAlignmentCenter];
//        [newTransit setText:@"walk for 10 mins"];
        newTransit.numberOfLines = 0;
        [self.scrollView addSubview:newTransit];
        
        UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, (i*140)+40, width, 90)];
        [newEvent setTextColor:white];
        [newEvent setBackgroundColor:turquoise];
        //TODO: find out why sometimes events are shown out of order in which they were input. Maybe switch to filters used in MVC.
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", [allInfo userInputs][i][@"type"]];
        NSArray *filteredArray = [[allInfo locationList] filteredArrayUsingPredicate:predicate];
        NSDictionary *location = filteredArray[0];
        
        NSString *text = [NSString stringWithFormat:@"  %@\r  %@",[location objectForKey:@"name"],[location objectForKey:@"userInput"]];
        [newEvent setText:text];
        newEvent.numberOfLines = 0;
        [self.scrollView addSubview:newEvent];
        
    }
    UILabel *timeLine = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, leftmargin-10, 600)];
    [timeLine setTextColor:turquoise];
    timeLine.numberOfLines = 0;
    NSMutableString *text = [NSMutableString stringWithString:@".\n"];
    for(int i = 9; i<12;i++){
        [text appendString:[NSString stringWithFormat:@"%dam\n",i]];
        [text appendString:@".\n.\n.\n.\n.\n.\n.\n"];
    }
    [text appendString:@"12pm\n"];
    [text appendString:@".\n.\n.\n.\n.\n.\n.\n.\n.\n.\n"];
    [timeLine setTextAlignment:NSTextAlignmentCenter];
    [timeLine setText:text];
    [timeLine setFont:[UIFont boldSystemFontOfSize:12]];
    [self.scrollView addSubview:timeLine];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (IBAction)addEventPressed:(UIButton*)sender{
    //TODO: possibly make allInfo a property of the class
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    if(![self.eventTypeField.text  isEqual: @""]){
        eventType = self.eventTypeField.text;
        
        
        if([[allInfo userInputs] containsObject:@{@"name": eventType,
                                                 @"type": eventType}]==NO){
            [[allInfo userInputs] insertObject:@{@"name": eventType,
                                                 @"type": eventType} atIndex:[allInfo size]];
            [allInfo setSize:[allInfo size]+1];
            
            UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
            UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
            
            UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(50, (([allInfo size]-1)*100)+40, 300, 90)];
            [newEvent setTextColor:white];
            [newEvent setBackgroundColor:turquoise];
            NSString *text = [NSString stringWithFormat:@"  %@\r%@",eventType,@"  9am"];
            [newEvent setText:text];
            [self.scrollView addSubview:newEvent];
        
        }
        self.eventTypeField.text = @"";
    }
}

- (IBAction)goToMap:(UIButton*)sender{
    [self performSegueWithIdentifier:@"showMap" sender:self];
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showMap"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.eventTypeInput = eventType;
        controller.eventList = eventList;
    }
}



@end