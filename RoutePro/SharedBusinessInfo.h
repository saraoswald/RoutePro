//
//  SharedBusinessInfo.h
//  RoutePro
//
//  Created by Sahil Pal on 5/4/16.
//  Copyright © 2016 nyu.edu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SharedBusinessInfo : NSObject{
    bool redraw;
    NSMutableArray *CachedBusinesses;
    NSMutableArray *SelectedBusinesses;
    NSMutableArray *eventList;
    NSMutableArray *locationList;
    NSMutableArray *userInputs;
    int size;
}

@property bool redraw;
@property (nonatomic, retain) NSMutableArray *CachedBusinesses;
@property (nonatomic, retain) NSMutableArray *SelectedBusinesses;
@property (nonatomic, retain) NSMutableArray *eventList;
@property (nonatomic, retain) NSMutableArray *locationList;
@property (nonatomic, retain) NSMutableArray *userInputs;
@property int size;

+ (id)sharedBusinessInfo;
- (NSMutableArray*) rerollItem: (int) index;
- (void)addText;
- (void)resetItems;

@end
