//
//  JYCalendarTitleBtn.m
//  FDCalendarDemo
//
//  Created by 姬巧春 on 16/6/15.
//  Copyright © 2016年 fergusding. All rights reserved.
//

#import "JYCalendarTitleBtn.h"

@implementation JYCalendarTitleBtn

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat imageX=(self.frame.size.width-100)*0.5;
    CGFloat imageY=contentRect.origin.y+10;
    CGFloat width=100;
    CGFloat height=23;
    return CGRectMake(imageX, imageY, width, height);
}

@end
