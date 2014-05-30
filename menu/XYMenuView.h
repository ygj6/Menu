//
//  MenuView.h
//  menu
//
//  Created by yuangongji on 12-9-9.
//  Copyright (c) 2012 yuangongji. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "common.h"


@protocol XYMenuViewDelegate;

#import "MenuUIModel.h"
#import "MenuDataModel.h"

@interface XYMenuView : UIScrollView<UIGestureRecognizerDelegate,MenuModelDelegate>

@property(nonatomic,assign)id<XYMenuViewDelegate> menuDelegate;

@property(nonatomic,assign)BOOL enableMultiply;
@property(nonatomic,assign)BOOL enableEdit;
@property(nonatomic,assign)BOOL multiplyAllwaysOnTail;
@property(nonatomic,strong)NSString *multiplyIconName;
@property(nonatomic,assign)CGSize elementSize;
@property(nonatomic,assign)XYMatrix matrix;
@property(nonatomic)XYMenuTitlePosition titlePosition;
@property(nonatomic,readonly)NSUInteger numberOfMenus;
@property(nonatomic,readonly)NSMutableArray *allMenus;
@property(nonatomic,assign)BOOL isEditing;


@property(nonatomic, strong)NSString *deleteButtonIconName;

- (void)displayGridWithTotalCount:(NSUInteger)count;
-(void)appendMenu:(MenuDataModel *)menuData animated:(BOOL)animated;
-(void)insertMenu:(MenuDataModel *)menuData atIndex:(NSUInteger)index animated:(BOOL)animated;
-(void)removeMenuWithUid:(NSString *)uid animated:(BOOL)animated;
-(void)endEditingAnimated:(BOOL)animated;

- (void)saveMenusToFile;
+ (NSArray *)readMenusFromFile;
- (void)clearup;
- (void)enumerateItemsUsingBlock:(void(^)(MenuUIModel *data, BOOL *stop))enumerateBlock;

@end

@protocol XYMenuViewDelegate <NSObject>

@optional

-(void)menuView:(XYMenuView*)view clickedMenu:(MenuDataModel*)model atIndex:(NSUInteger)index;
-(void)menuView:(XYMenuView*)view removedMenu:(MenuDataModel*)model atIndex:(NSUInteger)index;
-(void)menuView:(XYMenuView*)view clickedMultiplicationMenu:(NSUInteger)index;
-(void)menuView:(XYMenuView *)view didEndEditing:(NSArray*)allMenus;
-(BOOL)menuView:(XYMenuView *)view shouldRemoveMenu:(MenuDataModel*)model atIndex:(NSInteger)index;

-(void)menuView:(XYMenuView*)view moveMenuToTail:(MenuDataModel*)model;

-(void)menuView:(XYMenuView*)view exchangeMenu:(MenuDataModel*)newModel withMenuAtIndex:(NSUInteger)index;
- (void)menuView:(XYMenuView *)view orderDidChange:(NSArray *)allMenus;


@end


