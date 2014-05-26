//
//  MenuModel.m
//  menu
//
//  Created by yuangongji on 12-8-27.
//  Copyright (c) 2012 yuangongji. All rights reserved.
//
#import <QuartzCore/QuartzCore.h>
#import "MenuUIModel.h"

@interface MenuUIModel ()
{
    UILabel* titleLab;
    UIButton* iconBtn;
    UIButton* deltBtn;
    BOOL selects;
    UIImageView* badgeImg;
    UILabel* badgeLab;
    CGPoint center;
    
    UIImageView *hasNewImg;
}
-(void)wobble:(CGFloat)angle;
-(void)stopWobble;
-(void)iconClicked;
-(void)deltClicked;
@end

#define HEIGHT_RATIO 0.75
#define CORNOR_RATIO 0.35

#define ANGLE M_PI*1.0/180.0

@implementation MenuUIModel


- (void)refresh
{
    if (![_menuData.title isEqualToString:titleLab.text]) {
        titleLab.text = _menuData.title;
    }
    if (_menuData.icon == nil) {
    
        [iconBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }else {
        if (![[UIImage imageNamed:_menuData.icon] isEqual:[iconBtn backgroundImageForState:UIControlStateNormal]]) {
            
            [iconBtn setBackgroundImage:[UIImage imageNamed:_menuData.icon] forState:UIControlStateNormal];
        }
    }
    if (self.deleteButtonIconName) {
        [deltBtn setBackgroundImage:[UIImage imageNamed:self.deleteButtonIconName] forState:UIControlStateNormal];
    }else {
        [deltBtn setBackgroundImage:nil forState:UIControlStateNormal];
    }
    
    
    if (_menuData.active) {
        deltBtn.hidden=NO;
        iconBtn.enabled=NO;
        [self wobble:ANGLE];
    }else{
        deltBtn.hidden=YES;
        iconBtn.enabled=YES;
        [self stopWobble];
    }
    
    if (_menuData.badge > 0) {
        if (_menuData.badge > 99) {
            _menuData.badge = 99;
        }
//        badgeImg.image=[UIImage imageNamed:@"notebg.png"];
//        badgeLab.text=[NSString stringWithFormat:@"%d",_menuData.badge];
        hasNewImg.image=[UIImage imageNamed:@"hasNews"];
    }else{
        badgeImg.image=nil;
        badgeLab.text=nil;
        hasNewImg.image = nil;
    }
}
- (void)setMenuData:(MenuDataModel *)menuData
{
    if (![_menuData isEqual:menuData]) {
        _menuData = nil;
        _menuData = menuData;
        
        [self refresh];
    }
}

- (void)setBadge:(NSUInteger)badge
{
    if (_badge != badge) {
        
        _badge = badge;
        
        if (_badge>99) {
            _badge = 99;
        }
        if (badge == 0) {
//            badgeImg.image=nil;
//            badgeLab.text=nil;
            hasNewImg.image= nil;
        }else {
            // badgeImg.image=[UIImage imageNamed:@"notebg.png"];
            // badgeLab.text=[NSString stringWithFormat:@"%d",_badge];
            //badgeLab.text=[NSString stringWithFormat:@"%@",@"!"];
            hasNewImg.image=[UIImage imageNamed:@"hasNews"];
        }

    }
}
 /*


-(void)setIsActive:(BOOL)_isActive{
    isActive=_isActive;
    
    if (isActive) {
        deltBtn.hidden=NO;
        iconBtn.enabled=NO;
        [self wobble:ANGLE];
    }else{
        deltBtn.hidden=YES;
        iconBtn.enabled=YES;
        [self stopWobble];
    }
}
-(BOOL)isActive{
    return isActive;
}
-(void)setTitle:(NSString *)theTitle{
    
    titleLab.text=theTitle;
}
-(NSString *)title{
    return titleLab.text;
}
-(void)setIcon:(NSString *)iconName{
    [iconBtn setBackgroundImage:[UIImage imageNamed:iconName] forState:UIControlStateNormal];
}
-(NSString *)icon{
    return nil;
}
*/

- (void)addTitleLabel
{
    if (titleLab == nil) {
        titleLab=[[UILabel alloc]init];
        titleLab.textAlignment= NSTextAlignmentCenter;
        titleLab.backgroundColor=[UIColor clearColor];
        titleLab.textColor = [UIColor blackColor];
        [titleLab setFont:[UIFont systemFontOfSize:12.0]];
        [self addSubview:titleLab];
        titleLab.lineBreakMode = NSLineBreakByTruncatingHead;
        hasNewImg = [[UIImageView alloc] init];
        [self addSubview:hasNewImg];
    }
}

- (void)setMenuTitlePosition:(XYMenuTitlePosition)menuTitlePosition
{
    if (_menuTitlePosition != menuTitlePosition) {
        _menuTitlePosition = menuTitlePosition;
        
        if (menuTitlePosition != XYMenuTitlePositionNone) {
            
            [self addTitleLabel];
            
        }else {
            self.menuData.title = nil;
        }
        
        
        [self refresh];
    }
}
-(void)wobble:(CGFloat)angle
{
    CABasicAnimation* wob=[CABasicAnimation animationWithKeyPath:@"transform"];
    wob.duration=0.1;
    wob.autoreverses=YES;
    wob.removedOnCompletion=NO;
    wob.repeatCount=MAXFLOAT;
    wob.fromValue=[NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, angle, 0, 0, 1.0)];
    wob.toValue=[NSValue valueWithCATransform3D:CATransform3DRotate(self.layer.transform, -angle, 0, 0, 1.0)];
    [self.layer addAnimation:wob forKey:@"wobAnimation"];
}
-(void)stopWobble
{
    [self.layer removeAnimationForKey:@"wobAnimation"]; 
}


-(void)deltClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickDeleteButtonOnMenu:)]) {
        [self.delegate clickDeleteButtonOnMenu:self];
    }
}
-(void)iconClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickOnMenu:)]) {
        [self.delegate clickOnMenu:self];
    }
}
-(void)configMember
{
    
//    self.layer.borderColor =[[UIColor grayColor] CGColor];
//    self.layer.borderWidth =1.0;
    
    
    iconBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [iconBtn addTarget:self action:@selector(iconClicked) forControlEvents:UIControlEventTouchUpInside];
    iconBtn.enabled = YES;
    [self addSubview:iconBtn];
    
    
    deltBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    [deltBtn addTarget:self action:@selector(deltClicked) forControlEvents:UIControlEventTouchUpInside];
    deltBtn.hidden=YES;
    [self addSubview:deltBtn];
    
    badgeImg=[[UIImageView alloc]init];
    badgeImg.backgroundColor=[UIColor clearColor];
    [self addSubview:badgeImg];
    
    badgeLab=[[UILabel alloc]init];
    badgeLab.textAlignment= NSTextAlignmentCenter;
    badgeLab.font=[UIFont systemFontOfSize:12.f];
    badgeLab.textColor=[UIColor whiteColor];
    badgeLab.backgroundColor=[UIColor clearColor];
    [self addSubview:badgeLab];

}
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self configMember];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        [self configMember];

    }
    return self;
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat h=self.frame.size.height;
    CGFloat w=self.frame.size.width;

    
    [deltBtn setFrame:CGRectIntegral(CGRectMake(0, 0, w*CORNOR_RATIO, w*CORNOR_RATIO))];

    if (_menuTitlePosition == XYMenuTitlePositionCenter || _menuTitlePosition == XYMenuTitlePositionNone) {
        
        [iconBtn setFrame:CGRectIntegral(CGRectMake(w*0.5*CORNOR_RATIO, w*0.5*CORNOR_RATIO, w*(1.0-CORNOR_RATIO), h-w*0.5*CORNOR_RATIO))];
        
        [titleLab setFrame:CGRectIntegral(CGRectMake(w*0.5*CORNOR_RATIO, w*0.5*CORNOR_RATIO, w*(1.0-CORNOR_RATIO), h-w*0.5*CORNOR_RATIO))];
        
        [hasNewImg setFrame:CGRectIntegral(CGRectMake(w*0.5*CORNOR_RATIO - titleLab.frame.size.width/2 - 4, h-w*0.25*CORNOR_RATIO, 10, 10))];
        
    }else if (_menuTitlePosition == XYMenuTitlePositionBottom) {
        
        [iconBtn setFrame:CGRectIntegral(CGRectMake(w*0.5*CORNOR_RATIO, w*0.5*CORNOR_RATIO, w*(1.0-CORNOR_RATIO), h*HEIGHT_RATIO-w*0.5*CORNOR_RATIO))];
        
        titleLab.frame = CGRectIntegral(CGRectMake(0, h*HEIGHT_RATIO, w, h*(1.0-HEIGHT_RATIO)));
        
        CGFloat x = -2;
        if ([titleLab.text length] >= 5) {
            x = -12;
        }
        
        hasNewImg.frame = CGRectIntegral(CGRectMake(x, h*HEIGHT_RATIO + (h*(1.0-HEIGHT_RATIO)/2 - 5), 10, 10));
        
    }
    

    [badgeImg setFrame:CGRectIntegral(CGRectMake(w*(1-CORNOR_RATIO), 0, w*CORNOR_RATIO, w*CORNOR_RATIO))];
    [badgeLab setFrame:CGRectMake(w*(1-CORNOR_RATIO), 0, w*CORNOR_RATIO, w*CORNOR_RATIO-CORNOR_RATIO*6)];
    
#ifndef __OPTIMIZE__
    if (0) {
        self.layer.borderColor =[[UIColor redColor] CGColor];
        self.layer.borderWidth = 1.0;
        iconBtn.layer.borderColor =[[UIColor redColor] CGColor];
        iconBtn.layer.borderWidth = 1.0;
        titleLab.layer.borderColor =[[UIColor redColor] CGColor];
        titleLab.layer.borderWidth = 1.0;
        deltBtn.layer.borderColor =[[UIColor redColor] CGColor];
        deltBtn.layer.borderWidth = 1.0;
        badgeImg.layer.borderColor =[[UIColor redColor] CGColor];
        badgeImg.layer.borderWidth = 1.0;
        badgeLab.layer.borderColor =[[UIColor redColor] CGColor];
        badgeLab.layer.borderWidth = 1.0;
    }
#endif
}

- (void)dealloc
{
    self.menuData = nil;
    self.delegate = nil;
}
@end
