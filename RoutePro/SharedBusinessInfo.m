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

@synthesize coolbeans;
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
        coolbeans = @"Once";
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
    coolbeans = [NSString stringWithFormat:@"%@, once more", coolbeans];
}

- (void)printVals{
    NSLog(@"value of coolbeans is:::::::::: %@", coolbeans);
}

- (void)dealloc{
    
}

@end
