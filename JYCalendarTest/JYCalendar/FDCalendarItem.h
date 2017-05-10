//
//  FDCalendarItem.h
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DeviceWidth [UIScreen mainScreen].bounds.size.width

@class FDCalendarItem;

@protocol FDCalendarItemDelegate <NSObject>

- (void)calendarItem:(FDCalendarItem *)item didSelectedDate:(NSDate *)date;

@end


@interface FDCalendarItem : UIView

@property (strong, nonatomic) UICollectionView *collectionView;

@property (strong, nonatomic) NSDate *date;
@property (weak, nonatomic) id<FDCalendarItemDelegate> delegate;

@property ( nonatomic,strong) NSArray *redDianArray;

- (NSDate *)nextMonthDate;
- (NSDate *)previousMonthDate;

@end

