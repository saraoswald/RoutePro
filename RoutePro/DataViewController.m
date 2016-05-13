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
@synthesize untrackedChanges;


/* On load, populate the scrollview with any events that have been queried */
- (void)viewDidLoad {
    [super viewDidLoad];
    untrackedChanges=0;
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    
    if(!eventList){
        eventList = [[NSMutableArray alloc] init];
    }
    
    
    // make Timeline on side of view
    int scrollViewHeight = 1000;
    [self.scrollView setContentSize:CGSizeMake(300, scrollViewHeight)];
    
    UILabel *timeLine = [self drawTimeLine:scrollViewHeight];
    [self.scrollView addSubview:timeLine];

    
    // load events into timeline
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    int leftmargin = 50;
    int width = 300;
    for(int i=0;i<[allInfo size];i++){
        
        UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, (i*100)+10, width, 90)];
        [newEvent setTextColor:white];
        [newEvent setBackgroundColor:turquoise];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", [allInfo userInputs][i][@"type"]];
        NSArray *filteredArray = [[allInfo locationList] filteredArrayUsingPredicate:predicate];
        NSDictionary *location = filteredArray[0];
        
        NSString *text = [NSString stringWithFormat:@"  %@\r  %@\r  %@",[location objectForKey:@"name"],[location objectForKey:@"address"][0],[location objectForKey:@"userInput"]];
        [newEvent setText:text];
        newEvent.numberOfLines = 0;
        newEvent.tag = i;
        newEvent.userInteractionEnabled = YES;
        
        // add delete button
        UIButton *deleteButton = self.makeDeleteButton;
        [newEvent addSubview:deleteButton];
        // add reroll button
        UIButton *rerollButton = self.makeRerollButton;
        [newEvent addSubview:rerollButton];
        
        // add subview into scrolling area
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



/* Callback functions for finger presses */

// when plus sign is pressed
- (IBAction)addEventPressed:(UIButton*)sender{
    // get data from Yelp API
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    
    // if the text field isn't empty
    if(![self.eventTypeField.text  isEqual: @""]){
        eventType = self.eventTypeField.text;
        
        // for calculating how far down to place boxes
        int numSubviews = (int)[[self.scrollView subviews] count] - 2;
        if (numSubviews < 0)
            numSubviews = 1;
        // save input
        if([[allInfo userInputs] containsObject:@{@"name": eventType,
                                                  @"type": eventType}]==NO){
            [[allInfo userInputs] insertObject:@{@"name": eventType,
                                                 @"type": eventType} atIndex:[allInfo size]];
            [allInfo setSize:[allInfo size]+1];
            untrackedChanges=untrackedChanges+1;
            
            UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
            UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
            
            // create a label to place the new event in
            UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(50, (numSubviews*100)+10, 300, 90)];
            [newEvent setTextColor:white];
            [newEvent setBackgroundColor:turquoise];
            NSString *text = [NSString stringWithFormat:@"  %@\r%@",eventType,@"  9am"];
            [newEvent setText:text];
            newEvent.userInteractionEnabled = YES;
            
            // set tag of event (corresponds to index in allInfo)
            int index = (int)[[self.scrollView subviews] count] - 2; // index it at the bottom (beginning at 0)
            newEvent.tag = index;
            
            
            // add delete button
            UIButton *deleteButton = self.makeDeleteButton;
            [newEvent addSubview:deleteButton];
            
            
            // add event as a subview of the scrollview
            [self.scrollView addSubview:newEvent];
            
            
        }
        self.eventTypeField.text = @"";
    }
}

/* send rerollitem calls to the SharedBusinessInfo controller */

- (void)rerollItem: (int) index{
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    [allInfo rerollItem:index];
}

// reroll all items
- (IBAction)rerollPressed:(id)sender {
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    for(int i=0; i<[allInfo size]-untrackedChanges; i++){
        [self rerollItem:i];
    }
    [self redrawWithNewText];
}

// reroll single item
-(IBAction)rerollSinglePressed:(id)sender{
    UIButton *s = sender;
    int index = (int)s.superview.tag; // index of the event that needs to be rerolled
    NSLog(@"reroll index: %d", index);
    [self rerollItem:index];
    [self redrawWithNewText];
}

// remove all items from the scrollview
- (IBAction)removePressed:(id)sender {
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    [allInfo removeItem:0];
    for (UIView* vue in self.scrollView.subviews){
        [vue removeFromSuperview];
    }
    
    // add a timeline
    int scrollViewHeight = 1000;
    [self.scrollView setContentSize:CGSizeMake(300, scrollViewHeight)];
    UILabel *timeLine = [self drawTimeLine:scrollViewHeight];
    [self.scrollView addSubview:timeLine];
}


// remove single item from scrollview
-(IBAction)removeSinglePressed:(id)sender{
    // get index of the event that needs to be deleted
    UIButton *s = sender;
    int index = (int) s.superview.tag;
    NSLog(@"delete index: %d", index);
    
    // remove view from scrollview
    [s.superview removeFromSuperview];
    
    // remove item from list
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    [allInfo removeItem:index];
    
};

// generate subview for timeline based on what time it is
- (UILabel*) drawTimeLine:(int)scrollViewHeight{
    int leftmargin = 50;
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UILabel *timeLine = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, leftmargin-10, scrollViewHeight)];
    [timeLine setTextColor:turquoise];
    timeLine.numberOfLines = 0;
    NSMutableString *text = [NSMutableString stringWithString:@""];
    
    NSDate* now = [NSDate date];
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *dateComponents = [gregorian components:(NSCalendarUnitHour  | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:now];
    int hour = (int)[dateComponents hour];
    NSString *am_OR_pm=@"AM";
    
    if (hour>12)
    {
        hour=hour%12;
        
        am_OR_pm = @"PM";
    }
    
    int minute = (int)[dateComponents minute];
    
    NSMutableString *dots =[NSMutableString stringWithString:@""];
    for(int i=0;i<9;i++)
        [dots appendString:@"    .\n"];
    for(int i=minute;i<61;i+=6)
        [text appendString:@"    .\n"];
    if(minute>6)
        hour = hour + 1;
    if(hour == 12){
        [text appendString:@" 12pm\n"];
        [text appendString:dots];
        for(int i = 1; i<12;i++){
            [text appendString:[NSString stringWithFormat:@" %dpm\n",i]];
            [text appendString:dots];
        }
    }
    else if([am_OR_pm  isEqual: @"AM"]){
        for(int i = hour; i<12;i++){
            [text appendString:[NSString stringWithFormat:@" %dam\n",i]];
            [text appendString:dots];
        }
        [text appendString:@" 12pm\n"];
        [text appendString:dots];
        for(int i = 1; i<12;i++){
            [text appendString:[NSString stringWithFormat:@" %dpm\n",i]];
            [text appendString:dots];
        }
        
    }
    else{
        for(int i = hour; i<12;i++){
            [text appendString:[NSString stringWithFormat:@" %dpm\n",i]];
            [text appendString:dots];
        }
    }
    [text appendString:@" 12am\n"];
    [text appendString:dots];
    [timeLine setText:text];
    [timeLine setFont:[UIFont boldSystemFontOfSize:12]];
    
    return timeLine;
}

/* Redraw all the events onto the scrollview when needed */
- (void) redrawWithNewText{
    
    // delete all subviews currently in scrollview
    NSArray *viewsToRemove = [self.scrollView subviews];
    for (UIView *v in viewsToRemove) {
        [v removeFromSuperview];
    }
    
    // add a timeline to the side
    UILabel *timeLine = [self drawTimeLine:1000];
    [self.scrollView addSubview:timeLine];
    
    // get list of events
    SharedBusinessInfo *allInfo = [SharedBusinessInfo sharedBusinessInfo];
    
    // define constants
    UIColor *turquoise = [UIColor colorWithRed:(97.0/255.0) green:(195.0/255.0) blue:(139.0/255.0) alpha:1];
    UIColor *white = [UIColor colorWithWhite:1.0 alpha:1.0];
    int leftmargin = 50;
    int width = 300;
    
    // for each line in allInfo
    for(int i=0;i<[allInfo size];i++){
        // create label in the shape of a box
        UILabel *newEvent = [[UILabel alloc] initWithFrame:CGRectMake(leftmargin, (i*100)+10, width, 90)];
        [newEvent setTextColor:white];
        [newEvent setBackgroundColor:turquoise];
        
        // populate with data from Yelp API
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"userInput == %@", [allInfo userInputs][i][@"type"]];
        NSArray *filteredArray = [[allInfo locationList] filteredArrayUsingPredicate:predicate];
        NSDictionary *location = filteredArray[0];
        
        NSString *text = [[NSString alloc]init];
                if([[location objectForKey:@"address"]count]>0){
                        text = [NSString stringWithFormat:@"  %@\r  %@\r  %@",[location objectForKey:@"name"],[location objectForKey:@"address"][0],[location objectForKey:@"userInput"]];
                    }
                else{
                        text = [NSString stringWithFormat:@"  %@\r  \r  %@",[location objectForKey:@"name"], [location objectForKey:@"userInput"]];
                    }
        [newEvent setText:text];
        newEvent.numberOfLines = 0;
        newEvent.tag = i;
        newEvent.userInteractionEnabled = YES;
        
        // add delete button
        UIButton *deleteButton = self.makeDeleteButton;
        [newEvent addSubview:deleteButton];
        // add reroll button
        UIButton *rerollButton = self.makeRerollButton;
        [newEvent addSubview:rerollButton];
        
        // add subview into scrolling area
        [self.scrollView addSubview:newEvent];
        
    }
}

/* Generate buttons */

-(UIButton*) makeDeleteButton{
    UIButton *deleteButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 13, 25, 25)];
    UIImage *closeImage = [UIImage imageNamed:@"close"];
    deleteButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:[closeImage CGImage]
                                                                                      scale:(closeImage.scale * 2.0)
                                                                                orientation:(closeImage.imageOrientation)]];
    [deleteButton addTarget:self
                     action:@selector(removeSinglePressed:)
           forControlEvents:UIControlEventTouchUpInside];
    
    return deleteButton;
}

-(UIButton*) makeRerollButton{
    UIButton *rerollButton = [[UIButton alloc] initWithFrame:CGRectMake(265, 48, 25, 25)];
    UIImage *closeImage = [UIImage imageNamed:@"reroll"];
    rerollButton.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageWithCGImage:[closeImage CGImage]
                                                                                      scale:(closeImage.scale)
                                                                                orientation:(closeImage.imageOrientation)]];
    [rerollButton addTarget:self
                     action:@selector(rerollSinglePressed:)
           forControlEvents:UIControlEventTouchUpInside];
    
    return rerollButton;
}

/* Segue functions */

- (IBAction)goToMap:(UIButton*)sender{
    // need this since the segue is programmed
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