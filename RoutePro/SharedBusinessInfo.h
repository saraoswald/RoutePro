//
//  SharedBusinessInfo.h
//  RoutePro
//
//  Created by Sahil Pal on 5/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedBusinessInfo : NSObject{
    NSString *coolbeans;
    NSMutableArray *CachedBusinesses;
    NSMutableArray *SelectedBusinesses;
    NSMutableArray *eventList;
    NSMutableArray *locationList;
}

@property (nonatomic, retain) NSString *coolbeans;
@property (nonatomic, retain) NSMutableArray *CachedBusinesses;
@property (nonatomic, retain) NSMutableArray *SelectedBusinesses;
@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, retain) NSMutableArray *locationList;

+ (id)sharedBusinessInfo;
- (void)addText;
- (void)printVals;


@end
