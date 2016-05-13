//
//  SharedBusinessInfo.m
//  RoutePro
//
//  Created by Sahil Pal on 5/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import "SharedBusinessInfo.h"


@implementation SharedBusinessInfo

@synthesize redraw;
@synthesize CachedBusinesses;
@synthesize SelectedBusinesses;
@synthesize eventList;
@synthesize locationList;
@synthesize userInputs;
@synthesize size;


/**
 Initialize a sharedInfo object
 
 @return empty SharedBusinessInfo object
 */
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

/**
 Indicate that it is necessary to redraw items on timeline
 */
- (void)addText{
    redraw = YES;
}

/**
 Remove an item at a specific index in userInputs from all items in SharedBusinessInfo
 @param index: the index that will be removed
 */
- (void)removeItem: (int) index{
    //removes from userInputs
    if(index<[userInputs count]){
        NSString *term = userInputs[index][@"type"];
        [userInputs removeObjectAtIndex:index];
        
        //remove from locationList
        int llindex = -1;
        for(int i=0; i<[locationList count]; i++){
            if([locationList objectAtIndex:i][@"userInput"]==term){
                llindex = i;
            }
        }
        //only remove if the element was actually found
        if(llindex != -1){
            [locationList removeObjectAtIndex:llindex];
        }
        
        //remove from eventList
        int eventindex = -1;
        for(int i=0; i<[eventList count]; i++){
            if([eventList objectAtIndex:i][@"type"]==term){
                eventindex = i;
            }
        }
        //only remove if the element was actually found
        if(eventindex != -1){
            [eventList removeObjectAtIndex:eventindex];
        }
        
        //remove from SelectedBusinesses
        int selectindex = -1;
        for(int i=0; i<[SelectedBusinesses count]; i++){
            if([SelectedBusinesses objectAtIndex:i][@"type"]==term){
                selectindex = i;
            }
        }
        //only remove if the element was actually found
        if(selectindex != -1){
            [SelectedBusinesses removeObjectAtIndex:selectindex];
        }
        
        //remove from CachedBusinesses
        int cachedindex = -1;
        for(int i=0; i<[CachedBusinesses count]; i++){
            if([CachedBusinesses objectAtIndex:i][@"type"]==term){
                cachedindex = i;
            }
        }
        //only remove if the element was actually found
        if(cachedindex != -1){
            [CachedBusinesses removeObjectAtIndex:cachedindex];
        }
        
        size = size-1;
    }
    return;
}

/**
 Replace the leading item for a particular index with another item.
 @param index: index of item to be rerolled
 @return Empty NSMutableDicitonary object or newBusinessInfo
 */
- (NSMutableDictionary*)rerollItem: (int) index{
    //get the specific entry indexed by order of user inputs
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %@", userInputs[index][@"type"]];
    NSArray *filteredArray = [CachedBusinesses filteredArrayUsingPredicate:predicate];
    NSMutableArray *businesses = [[NSMutableArray alloc]init];
    if([filteredArray count]>0){
        businesses = filteredArray[0][@"bArray"];
    }
    //remove the first object, the second becomes the new item that will be used
    NSMutableArray *tmp = [[NSMutableArray alloc] init];
    for(int i=1; i<[businesses count]; i++){
        [tmp insertObject:[businesses objectAtIndex:i] atIndex:(i-1)];
    }
    businesses = tmp;
    
    //this is the new business that we have chosen for the replacement
    if([businesses count]>0){
        NSMutableDictionary *newBusinessInfo = businesses[0];
        
        //this should reaplce the value of the bArray with the bArray that has removed a value
        NSUInteger replaceIndex = [CachedBusinesses indexOfObject:filteredArray[0]];
        CachedBusinesses[replaceIndex][@"bArray"]=businesses;
        
        //now replace value in selected array
        NSArray *filteredArray2 = [SelectedBusinesses filteredArrayUsingPredicate:predicate];
        NSUInteger replaceIndex2 = [SelectedBusinesses indexOfObject:filteredArray2[0]];
        SelectedBusinesses[replaceIndex2][@"name"]=newBusinessInfo[@"name"];
        
        //now change value in event list
        NSArray *filteredArray3 = [eventList filteredArrayUsingPredicate:predicate];
        NSUInteger replaceIndex3 = [eventList indexOfObject:filteredArray3[0]];
        eventList[replaceIndex3][@"name"]=newBusinessInfo[@"name"];
        
        //now change the value in locationList
        NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"userInput == %@", userInputs[index][@"type"]];
        NSArray *filteredArray4 = [locationList filteredArrayUsingPredicate:predicate2];
        NSUInteger replaceIndex4 = [locationList indexOfObject:filteredArray4[0]];
        locationList[replaceIndex4][@"name"]=newBusinessInfo[@"name"];
        locationList[replaceIndex4][@"latitude"]=newBusinessInfo[@"location"][@"coordinate"][@"latitude"];
        locationList[replaceIndex4][@"longitude"]=newBusinessInfo[@"location"][@"coordinate"][@"longitude"];
        locationList[replaceIndex4][@"address"]=newBusinessInfo[@"location"][@"address"];

        return newBusinessInfo;
    }
    return [[NSMutableDictionary alloc]init];
}


/**
 Reinitialize the items in SharedBusinessInfo.
 */
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
