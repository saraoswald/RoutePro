//
//  SharedBusinessInfo.m
//  RoutePro
//
//  Created by Sahil Pal on 5/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "SharedBusinessInfo.h"


//TODO: start saving businesses into the cache, make sure that there aren't multiple calls to YPAPI. Also gives easy access to potential rerolls for items. As bandage fix, remove the business re-rolled and select the next top item as the re-rolled destination. Also keep track of selected businesses in this helpful array.

@implementation SharedBusinessInfo

@synthesize redraw;
@synthesize CachedBusinesses;
@synthesize SelectedBusinesses;
@synthesize eventList;
@synthesize locationList;
@synthesize userInputs;
@synthesize size;

+ (id)sharedBusinessInfo{
    static SharedBusinessInfo *sharedInfo = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInfo = [[self alloc] init];
    });
    return sharedInfo;
}

- (id)init {
    if(self = [super init]){
        redraw = NO;
        CachedBusinesses = [[NSMutableArray alloc] init];
        SelectedBusinesses = [[NSMutableArray alloc] init];
        eventList = [[NSMutableArray alloc] init];
        locationList = [[NSMutableArray alloc] init];
        userInputs = [[NSMutableArray alloc] init];
        size=0;
    }
    return self;
};

//TODO: remove these methods, used for singleton testing
- (void)addText{
//    [NSString stringWithFormat:@"%f,%f",[location[@"latitude"] floatValue],[location[@"longitude"] floatValue]]
    //coolbeans+="once more";
    redraw = YES;
}



//remove the item currently here from the selected business array and replace the item with something else from the same index of the cached business array. Confirm what changes need to be made to the locationlist and eventlist arrays.
- (NSMutableDictionary*)rerollItem: (int) index{
    //get the specific entyry indexed by order of user inputs
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", userInputs[index][@"type"]];
    NSArray *filteredArray = [CachedBusinesses filteredArrayUsingPredicate:predicate];
    NSMutableArray *businesses = filteredArray[0][@"bArray"];
    
    //remove the first object, the second becomes the new item that will be used
//    [businesses removeObjectAtIndex:0];
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for(int i=1; i<[businesses count]; i++){
        [tmp insertObject:[businesses objectAtIndex:i] atIndex:(i-1)];
    }
    businesses = tmp;
    
    //this is the new business that we have chosen for the replacement
    NSMutableDictionary *newBusinessInfo = businesses[0];
    
    //this should reaplce the value of the bArray with the bArray that has removed a value
    NSUInteger replaceIndex = [CachedBusinesses indexOfObject:filteredArray[0]];
//    int replacementIndex = (int) replaceIndex;
    CachedBusinesses[replaceIndex][@"bArray"]=businesses;
    
    //now replace value in selected array
    NSArray *filteredArray2 = [SelectedBusinesses filteredArrayUsingPredicate:predicate];
    NSUInteger replaceIndex2 = [SelectedBusinesses indexOfObject:filteredArray2[0]];
//    int replacementIndex2 = (int) replaceIndex2;
    SelectedBusinesses[replaceIndex2][@"name"]=newBusinessInfo[@"name"];
    
    //now change value in event list
    NSArray *filteredArray3 = [eventList filteredArrayUsingPredicate:predicate];
    NSUInteger replaceIndex3 = [eventList indexOfObject:filteredArray3[0]];
//    int replacementIndex3 = (int) replaceIndex3;
    eventList[replaceIndex3][@"name"]=newBusinessInfo[@"name"];
    
    //now change the value in locationList
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"userInput == %@", userInputs[index][@"type"]];
    NSArray *filteredArray4 = [locationList filteredArrayUsingPredicate:predicate2];
    NSUInteger replaceIndex4 = [locationList indexOfObject:filteredArray4[0]];
    locationList[replaceIndex4][@"name"]=newBusinessInfo[@"name"];
    locationList[replaceIndex4][@"latitude"]=newBusinessInfo[@"location"][@"coordinate"][@"latitude"];
    locationList[replaceIndex4][@"longitude"]=newBusinessInfo[@"location"][@"coordinate"][@"longitude"];
    locationList[replaceIndex4][@"address"]=newBusinessInfo[@"location"][@"address"];
//
//    [tmpObject setObject:topBusinessJSON[@"name"] forKey:@"name"];
//    [tmpObject setObject:term forKey:@"userInput"];
//    [tmpObject setObject:latitude forKey:@"latitude"];
//    [tmpObject setObject:longitutde forKey:@"longitude"];
    
    return newBusinessInfo;
}

- (void)resetItems{
    redraw = NO;
    CachedBusinesses = [[NSMutableArray alloc] init];
    SelectedBusinesses = [[NSMutableArray alloc] init];
    eventList = [[NSMutableArray alloc] init];
    locationList = [[NSMutableArray alloc] init];
    userInputs = [[NSMutableArray alloc] init];
    size=0;
}


- (void)dealloc{
    
}

@end
