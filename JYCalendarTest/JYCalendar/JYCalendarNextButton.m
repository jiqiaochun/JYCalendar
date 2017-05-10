//
//  JYCalendarNextBtn.m
//  减约
//
//  Created by 姬巧春 on 16/6/7.
//  Copyright © 2016年 北京减脂时代科技有限公司. All rights reserved.
//

#import "JYCalendarNextButton.h"

@implementation JYCalendarNextButton

- (CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat imageX=50;
    CGFloat imageY=contentRect.origin.y+10;
    CGFloat width=100;
    CGFloat height=23;
    return CGRectMake(imageX, imageY, width, height);
}

@end
