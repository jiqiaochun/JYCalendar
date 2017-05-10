//
//  ViewController.m
//  JYCalendarTest
//
//  Created by 姬巧春 on 16/6/15.
//  Copyright © 2016年 姬巧春. All rights reserved.
//

#import "ViewController.h"
#import "FDCalendar.h"

@interface ViewController () <FDCalendarDelegate>
@property (nonatomic,strong) UIButton *btn;
@property (nonatomic,copy) NSDate *selectedDate;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.selectedDate = [NSDate date];
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    btn.backgroundColor = [UIColor redColor];
    [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    self.btn = btn;
}

- (void)btnClick:(UIButton *)btn{
    FDCalendar *calendar = [[FDCalendar alloc] initWithCurrentDate:self.selectedDate];
    CGRect frame = calendar.frame;
    calendar.delegate = self;
    frame.origin.y = 64;
    calendar.frame = frame;
    [self.view addSubview:calendar];
    [calendar showCalendar];
    
    calendar.centerCalendarItem.redDianArray = @[@"2016-06-04",@"2016-06-07",@"2016-06-010",@"2016-06-012"];
    [calendar.centerCalendarItem.collectionView reloadData];
}

- (void)hasChangeToDate:(NSString *)date{
    if (date.length == 10) {
        
        // 字符串转日期
        NSDateFormatter *Formatter= [[NSDateFormatter alloc] init];
        [Formatter setDateFormat:@"yyyy-MM-dd"];
        self.selectedDate = [Formatter dateFromString:date];
        
        NSString *strneed = [date substringFromIndex:5];
        NSLog(@"%@",strneed);
        [self.btn setTitle:strneed forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
