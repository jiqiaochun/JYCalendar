//
//  FDCalendar.m
//  FDCalendarDemo
//
//  Created by fergusding on 15/8/20.
//  Copyright (c) 2015年 fergusding. All rights reserved.
//

#import "FDCalendar.h"
#import "FDCalendarItem.h"

#import "JYCalendarTitleBtn.h"
#import "JYCalendarPreButton.h"
#import "JYCalendarNextButton.h"

#define Weekdays @[@"日", @"一", @"二", @"三", @"四", @"五", @"六"]
#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)

static NSDateFormatter *dateFormattor;

@interface FDCalendar () <UIScrollViewDelegate, FDCalendarItemDelegate>

@property (strong, nonatomic) NSDate *date;
@property (strong, nonatomic) NSDate *selecteddate;

@property (strong, nonatomic) JYCalendarTitleBtn *titleButton;
@property (nonatomic,strong) JYCalendarPreButton *leftButton;
@property (nonatomic,strong) JYCalendarNextButton *rightButton;
@property (strong, nonatomic) UIScrollView *scrollView;

@property (strong, nonatomic) UIView *backgroundView;
@property (strong, nonatomic) UIView *datePickerView;
@property (strong, nonatomic) UIDatePicker *datePicker;

@end

@implementation FDCalendar

- (instancetype)initWithCurrentDate:(NSDate *)date{
    if (self = [super init]) {
        self.backgroundColor = [UIColor whiteColor];
        self.date = date;
        self.selecteddate = self.date;
        
        [self setupTitleBar];
        [self setupWeekHeader];
        [self setupCalendarItems];
        [self setupScrollView];
        [self setFrame:CGRectMake(0, 0, DeviceWidth, CGRectGetMaxY(self.scrollView.frame))];
        
        [self setCurrentDate:self.date];
    }
    return self;
}

#pragma mark - Custom Accessors

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] initWithFrame: CGRectMake(0, 64, SCREEN_WIDTH, SCREEN_HEIGHT-64)];
        _backgroundView.backgroundColor = [UIColor blackColor];
        _backgroundView.alpha = 0;
        
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideDatePickerView)];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideCalendar)];
        [_backgroundView addGestureRecognizer:tapGesture];
    }
    
//    [self.superview addSubview:_backgroundView];
    [self.superview insertSubview:_backgroundView belowSubview:self];
    
    return _backgroundView;
}

- (UIView *)datePickerView {
    if (!_datePickerView) {
        _datePickerView = [[UIView alloc] initWithFrame:CGRectMake(0, 44, self.frame.size.width, 0)];
        _datePickerView.backgroundColor = [UIColor whiteColor];
        _datePickerView.clipsToBounds = YES;
        
        UIButton *cancelButton = [[UIButton alloc] initWithFrame:CGRectMake(20, 10, 32, 20)];
        cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        [cancelButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [cancelButton addTarget:self action:@selector(cancelSelectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:cancelButton];
        
        UIButton *okButton = [[UIButton alloc] initWithFrame:CGRectMake(self.frame.size.width - 52, 10, 32, 20)];
        okButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        [okButton setTitle:@"确定" forState:UIControlStateNormal];
        [okButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [okButton addTarget:self action:@selector(selectCurrentDate) forControlEvents:UIControlEventTouchUpInside];
        [_datePickerView addSubview:okButton];
        
        [_datePickerView addSubview:self.datePicker];
    }
    
    [self addSubview:_datePickerView];
    
    return _datePickerView;
}

- (UIDatePicker *)datePicker {
    if (!_datePicker) {
        _datePicker = [[UIDatePicker alloc] init];
        _datePicker.datePickerMode = UIDatePickerModeDate;
        _datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"Chinese"];
        CGRect frame = _datePicker.frame;
        frame.origin = CGPointMake(0, 32);
        _datePicker.frame = frame;
    }
    
    return _datePicker;
}

#pragma mark - Private

- (NSString *)stringFromDate:(NSDate *)date {
    if (!dateFormattor) {
        dateFormattor = [[NSDateFormatter alloc] init];
        [dateFormattor setDateFormat:@"yyyy年MM月"];
    }
    return [dateFormattor stringFromDate:date];
}

// 设置上层的titleBar
- (void)setupTitleBar {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, DeviceWidth, 44)];
    titleView.backgroundColor = [UIColor redColor];
    [self addSubview:titleView];
    
    JYCalendarPreButton *leftButton = [[JYCalendarPreButton alloc] initWithFrame:CGRectMake(-(SCREEN_WIDTH*0.25), 0, SCREEN_WIDTH*0.5, 44)];
//    [leftButton setImage:[UIImage imageNamed:@"icon_previous"] forState:UIControlStateNormal];
    leftButton.titleLabel.textColor = [UIColor lightGrayColor];
    leftButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [leftButton addTarget:self action:@selector(setPreviousMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:leftButton];
    self.leftButton = leftButton;
    
    JYCalendarTitleBtn *titleButton = [[JYCalendarTitleBtn alloc] initWithFrame:CGRectMake(SCREEN_WIDTH*0.25, 0, SCREEN_WIDTH*0.5, 44)];
    titleButton.titleLabel.textColor = [UIColor whiteColor];
    titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    titleButton.center = titleView.center;
    //    [titleButton addTarget:self action:@selector(showDatePicker) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:titleButton];
    self.titleButton = titleButton;
    
    JYCalendarNextButton *rightButton = [[JYCalendarNextButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.titleButton.frame), 0, SCREEN_WIDTH*0.5, 44)];
//    [rightButton setImage:[UIImage imageNamed:@"icon_next"] forState:UIControlStateNormal];
    rightButton.titleLabel.textColor = [UIColor lightGrayColor];
    rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:17];
    [rightButton addTarget:self action:@selector(setNextMonthDate) forControlEvents:UIControlEventTouchUpInside];
    [titleView addSubview:rightButton];
    self.rightButton = rightButton;
}

// 设置星期文字的显示
- (void)setupWeekHeader {
    NSInteger count = [Weekdays count];
    CGFloat offsetX = 5;
    for (int i = 0; i < count; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetX, 50, (DeviceWidth - 10) / count, 20)];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        weekdayLabel.text = Weekdays[i];
        
        if (i == 0 || i == count - 1) {
            weekdayLabel.textColor = [UIColor redColor];
        } else {
            weekdayLabel.textColor = [UIColor grayColor];
        }
        
        [self addSubview:weekdayLabel];
        offsetX += weekdayLabel.frame.size.width;
    }
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(15, 74, DeviceWidth - 30, 1)];
    lineView.backgroundColor = [UIColor lightGrayColor];
    [self addSubview:lineView];
}

// 设置包含日历的item的scrollView
- (void)setupScrollView {
    self.scrollView.delegate = self;
    self.scrollView.pagingEnabled = YES;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.scrollView setFrame:CGRectMake(0, 75, DeviceWidth, self.centerCalendarItem.frame.size.height)];
//    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
    [self addSubview:self.scrollView];
}

// 设置3个日历的item
- (void)setupCalendarItems {
    self.scrollView = [[UIScrollView alloc] init];
    
    self.leftCalendarItem = [[FDCalendarItem alloc] init];
    [self.scrollView addSubview:self.leftCalendarItem];
    
    CGRect itemFrame = self.leftCalendarItem.frame;
    itemFrame.origin.x = DeviceWidth;
    self.centerCalendarItem = [[FDCalendarItem alloc] init];
    self.centerCalendarItem.frame = itemFrame;
    self.centerCalendarItem.delegate = self;
    [self.scrollView addSubview:self.centerCalendarItem];
    
    itemFrame.origin.x = DeviceWidth * 2;
    self.rightCalendarItem = [[FDCalendarItem alloc] init];
    self.rightCalendarItem.frame = itemFrame;
    [self.scrollView addSubview:self.rightCalendarItem];
}

// 设置当前日期，初始化
- (void)setCurrentDate:(NSDate *)date {
    self.centerCalendarItem.date = date;
    self.leftCalendarItem.date = [self.centerCalendarItem previousMonthDate];
    self.rightCalendarItem.date = [self.centerCalendarItem nextMonthDate];
    
    
    NSTimeInterval timeBetween = [self isBigCurrentDate:[NSDate date] selectedDate:self.centerCalendarItem.date];
    if (timeBetween <= 0) {
        [self.rightButton setTitle:@"" forState:UIControlStateNormal];
    }else{
        [self.rightButton setTitle:[self stringFromDate:self.rightCalendarItem.date] forState:UIControlStateNormal];
    }
    
    [self.leftButton setTitle:[self stringFromDate:self.leftCalendarItem.date] forState:UIControlStateNormal];
    [self.titleButton setTitle:[self stringFromDate:self.centerCalendarItem.date] forState:UIControlStateNormal];
    
}

// 重新加载日历items的数据
- (void)reloadCalendarItems {
    
    CGPoint offset = self.scrollView.contentOffset;
    
    if (offset.x == self.scrollView.frame.size.width) { //防止滑动一点点并不切换scrollview的视图
        return;
    }
    
    if (offset.x > self.scrollView.frame.size.width) {
        [self setNextMonthDate];
    } else {
        [self setPreviousMonthDate];
    }
    
    self.scrollView.contentOffset = CGPointMake(self.scrollView.frame.size.width, 0);
}

- (void)showDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0.4;
        self.datePickerView.frame = CGRectMake(0, 44, self.frame.size.width, 250);
    }];
}

- (void)hideDatePickerView {
    [UIView animateWithDuration:0.25 animations:^{
        self.backgroundView.alpha = 0;
        self.datePickerView.frame = CGRectMake(0, 44, self.frame.size.width, 0);
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self.datePickerView removeFromSuperview];
    }];
}

#pragma mark - SEL

// 跳到上一个月
- (void)setPreviousMonthDate {
    NSTimeInterval timeBetween = [self isBigCurrentDate:self.date selectedDate:[self.centerCalendarItem previousMonthDate]];
    if (timeBetween < 0) {
        return;
    }
    
    
    // 日期转字符串
    NSDateFormatter *outputFormatter1 = [[NSDateFormatter alloc] init];
    [outputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [outputFormatter1 stringFromDate:[self.centerCalendarItem previousMonthDate]];
    strDate = [strDate substringToIndex:10];
    
    if ([self.delegate respondsToSelector:@selector(hasChangeToDate:)]) {
        [self.delegate hasChangeToDate:strDate];
    }
    [self setCurrentDate:[self.centerCalendarItem previousMonthDate]];
    
    self.centerCalendarItem.redDianArray = @[@"2016-05-23",@"2016-05-07",@"2016-05-15",@"2016-05-01"];
    [self.centerCalendarItem.collectionView reloadData];

}

// 跳到下一个月
- (void)setNextMonthDate {
    NSTimeInterval timeBetween = [self isBigCurrentDate:self.date selectedDate:[self.centerCalendarItem nextMonthDate]];
    if (timeBetween < 0) {
        return;
    }
    
    // 日期转字符串
    NSDateFormatter *outputFormatter1 = [[NSDateFormatter alloc] init];
    [outputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [outputFormatter1 stringFromDate:[self.centerCalendarItem nextMonthDate]];
    strDate = [strDate substringToIndex:10];
    
    if ([self.delegate respondsToSelector:@selector(hasChangeToDate:)]) {
        [self.delegate hasChangeToDate:strDate];
    }
    [self setCurrentDate:[self.centerCalendarItem nextMonthDate]];
    
    self.centerCalendarItem.redDianArray = @[@"2016-05-23",@"2016-05-07",@"2016-05-15",@"2016-05-01"];
    [self.centerCalendarItem.collectionView reloadData];

}

- (void)showCalendar{
    self.transform = CGAffineTransformTranslate(self.transform, 0, - self.frame.size.height);
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCurlUp animations:^{
        self.transform = CGAffineTransformIdentity;
        self.backgroundView.alpha = 0.5;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)hideCalendar{
    [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionTransitionCurlDown animations:^{
        self.transform = CGAffineTransformTranslate(self.transform, 0, -self.frame.size.height);
        self.backgroundView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.backgroundView removeFromSuperview];
        [self removeFromSuperview];
    }];
}

- (void)showDatePicker {
    [self showDatePickerView];
}

// 选择当前日期
- (void)selectCurrentDate {
    [self setCurrentDate:self.datePicker.date];
    [self hideDatePickerView];
}

- (void)cancelSelectCurrentDate {
    [self hideDatePickerView];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSTimeInterval timeBetween = [self isBigCurrentDate:[NSDate date] selectedDate:[self.centerCalendarItem nextMonthDate]];
    if (timeBetween < 0) {
        self.scrollView.contentSize = CGSizeMake(2 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        return;
    }
    
    self.scrollView.contentSize = CGSizeMake(3 * self.scrollView.frame.size.width, self.scrollView.frame.size.height);
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self reloadCalendarItems];
}

#pragma mark - FDCalendarItemDelegate

- (void)calendarItem:(FDCalendarItem *)item didSelectedDate:(NSDate *)date {
    
    NSTimeInterval timeBetween = [self isBigCurrentDate:[NSDate date] selectedDate:date];
    if (timeBetween < 0) {
        self.selecteddate = [NSDate date];
        return;
    }
    self.selecteddate = date;
    
    // 日期转字符串
    NSDateFormatter *outputFormatter1 = [[NSDateFormatter alloc] init];
    [outputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [outputFormatter1 stringFromDate:date];
    strDate = [strDate substringToIndex:10];
    if ([self.delegate respondsToSelector:@selector(hasChangeToDate:)]) {
        [self.delegate hasChangeToDate:strDate];
    }
    [self setCurrentDate:self.selecteddate];
    
    [self hideCalendar];
}

#pragma - mark 判断是否大于当前日期
- (NSTimeInterval)isBigCurrentDate:(NSDate *)currentDate selectedDate:(NSDate *)selectedDate{
    // 大于当前日期
    
    // 日期转字符串
    NSDateFormatter *outputFormatter1 = [[NSDateFormatter alloc] init];
    [outputFormatter1 setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *str = [outputFormatter1 stringFromDate:currentDate];
    str = [str substringToIndex:10];
    // 字符串转日期
    NSDateFormatter *Formatter= [[NSDateFormatter alloc] init];
    [Formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate*needDate = [Formatter dateFromString:str];
    
    // 日期转字符串
    NSDateFormatter *curFormatter = [[NSDateFormatter alloc] init];
    [curFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *curStr = [curFormatter stringFromDate:selectedDate];
    curStr = [curStr substringToIndex:10];
    // 字符串转日期
    NSDateFormatter *curdateFormatter= [[NSDateFormatter alloc] init];
    [curdateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate*curDate = [curdateFormatter dateFromString:curStr];
    
    NSTimeInterval timeBetween = [needDate timeIntervalSinceDate:curDate];
    return timeBetween;
}

@end
