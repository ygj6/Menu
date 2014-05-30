//
//  MenuModel.h
//  menu
//
//  Created by yuangongji on 12-8-27.
//  Copyright (c) 2012 yuangongji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDataModel.h"

typedef enum : NSUInteger {
    
    XYMenuTitlePositionNone,
    XYMenuTitlePositionBottom,
    XYMenuTitlePositionCenter
    
} XYMenuTitlePosition;

@protocol MenuModelDelegate;

@interface MenuUIModel : UIView<UIGestureRecognizerDelegate>

@property(nonatomic, strong)MenuDataModel *menuData;
@property(nonatomic, assign)id<MenuModelDelegate> delegate;
@property(nonatomic)XYMenuTitlePosition menuTitlePosition;
@property(nonatomic)NSUInteger badge;
@property(nonatomic, strong)NSString *deleteButtonIconName;

- (void)refresh;
@end

@protocol MenuModelDelegate <NSObject>

- (void)clickOnMenu:(MenuUIModel *)model;
- (void)clickDeleteButtonOnMenu:(MenuUIModel *)model;

@end