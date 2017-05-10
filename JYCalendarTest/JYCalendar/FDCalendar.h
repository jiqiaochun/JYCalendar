//
//  FDCalendar.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FDCalendarItem.h"

@protocol FDCalendarDelegate <NSObject>

- (void)hasChangeToDate:(NSString*)date;

@end

@interface FDCalendar : UIView

@property ( nonatomic,assign) id<FDCalendarDelegate> delegate;

@property (strong, nonatomic) FDCalendarItem *leftCalendarItem;
@property (strong, nonatomic) FDCalendarItem *centerCalendarItem;
@property (strong, nonatomic) FDCalendarItem *rightCalendarItem;

- (instancetype)initWithCurrentDate:(NSDate *)date;

- (void)showCalendar;

@end
