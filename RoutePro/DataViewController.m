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
    NSMutableString *displayEventList = [[NSMutableString alloc] init];
    NSString *temp = [[NSString alloc] init];
    for(int i=0;i<[eventList count]; i++){
      temp = [NSString stringWithFormat:@"eventList[%d] = %@,%@\n",i,[eventList[i] objectForKey:@"name"],[eventList[i] objectForKey:@"type"]];
      [displayEventList appendString:temp];
    }
    self.testText.text = displayEventList;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.dataLabel.text = [self.dataObject description];
}

- (IBAction)addEventPressed:(UIButton*)sender{
    eventType = self.eventTypeField.text;
    eventType1 = self.eventTypeField1.text;
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showMap"]){
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.eventTypeInput = eventType;
        controller.eventTypeInput1 = eventType1;
        controller.eventList = eventList;
    }
}

// Table view stuff
- (UITableViewCell *)eventListTable:(UITableView *)eventListTable cellForRowAtIndexPath:(NSIndexPath *)indexPath{

        static NSString *MyIdentifier = @"eventCell";

        UITableViewCell *cell =[eventListTable dequeueReusableCellWithIdentifier:MyIdentifier];
        if (cell == nil){
            cell = [[UITableViewCell alloc] init];
        }

    cell.textLabel.text = [eventList[indexPath.row] objectForKey:@"name"];
    NSLog(@"%@",cell.textLabel.text);
    return cell;

}
- (NSInteger)eventListTable:(UITableView *)eventListTable numberOfRowsInSection:(NSInteger)section {
   // Return the number of rows in the section.
   // If you're serving data from an array, return the length of the array:
   return [eventList count];
}
@end
