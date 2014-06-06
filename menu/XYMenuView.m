//
//  MenuView.m
//  menu
//
//  Created by yuangongji on 12-9-9.
//  Copyright (c) 2012 yuangongji. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "XYMenuView.h"
#import "MenuUIModel.h"

#define ANGLE M_PI*2.5/180.0
#define FilePathInDoc(s) [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:(s)]


@interface XYMenuView()
{
    CGPoint loc0;
    CGPoint previous;
    NSInteger current;
    MenuUIModel* currentMenu;

    UITapGestureRecognizer* tap;
    MenuUIModel* multiplicationMenu;
    
    NSUInteger gridCount;
}
-(void)handleLongPress:(UILongPressGestureRecognizer*)gesture;
-(void)handleTap:(UITapGestureRecognizer*)gesture;
-(void)sortAllMenuAnimated:(BOOL)animated;
-(void)resetSerialAfterMoveMenu:(MenuUIModel *)menu;
-(void)resetSerialAfterDeleteMenu:(NSInteger)serial;
-(void)resetSerialAfterInsertMenu:(NSInteger)serial;
-(NSUInteger)areaContainsPoint:(CGPoint)loc;
static int ceilingf(float f);
-(void)addTapGesture;
-(void)awakenMultiplication:(NSInteger)fromIndex;

@end


@implementation XYMenuView

@synthesize menuDelegate;

-(void)initialize
{
    _enableEdit=YES;
    _enableMultiply=YES;
    _matrix = XYMatrixMake(1, 1);
    self.showsHorizontalScrollIndicator=NO;
    self.showsVerticalScrollIndicator=NO;
    self.backgroundColor =[UIColor clearColor];
    self.multiplyIconName = @"multiply3.png";
    self.deleteButtonIconName = @"deletebtn.png";
}
-(id)init
{
    self=[super init];
    if (self) {
        [self initialize];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}
-(id)initWithFrame:(CGRect)frame
{
    self=[super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (NSUInteger)numberOfMenus
{
    NSUInteger ret=0;
    for (UIView* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]] && v != multiplicationMenu) {
            ret++;
        }
    }
    return ret;
}

- (CGRect)gridForIndex:(NSUInteger)index
{
    CGSize size = self.bounds.size;
    CGRect validFrame = CGRectMake(self.contentInset.left, self.contentInset.top, size.width - self.contentInset.left - self.contentInset.right, size.height - self.contentInset.top - self.contentInset.bottom);
    CGFloat uw = validFrame.size.width / _matrix.column;
    CGFloat uh = validFrame.size.height / _matrix.row;
    
    int page = (int)index / (_matrix.column * _matrix.row);
    int row = (int)index % (_matrix.column * _matrix.row) / _matrix.column;
    int col = (int)index % (_matrix.column * _matrix.row) % _matrix.column;
    
    CGFloat x = size.width * page + col * uw + validFrame.origin.x;
    CGFloat y = row * uh + validFrame.origin.y;
    
    return CGRectIntegral(CGRectMake(x, y, uw, uh));
}

- (CGPoint)getMenuCenter:(int)count
{
    CGRect frame = [self gridForIndex:count];
    return CGPointMake((int)(frame.origin.x + frame.size.width * 0.5), (int)(frame.origin.y + frame.size.height * 0.5));
}
- (CGPoint)getMenuCenter2:(int)count
{
    CGFloat w=self.bounds.size.width;
    CGFloat h=self.bounds.size.height;
    CGFloat xval=(count% _matrix.column *w+w/2.0)/_matrix.column+w*(ceilingf((count+1.0)/(_matrix.column * _matrix.row))-1);
    CGFloat yval=((int)(count%(_matrix.row * _matrix.column)/ _matrix.column)*h+h/2.0)/_matrix.row;
    
    return CGPointMake(xval, yval);
}

#pragma mark ----------View Layout

- (void)appendMenu:(MenuDataModel *)menuData animated:(BOOL)animated
{
    NSUInteger index = [self numberOfMenus];
    [self insertMenu:menuData atIndex:index animated:animated];

}

- (void)insertMenu:(MenuDataModel *)menuData atIndex:(NSUInteger)index animated:(BOOL)animated
{
    NSUInteger cnt = [self numberOfMenus];
    if (index > cnt) {
        return;
    }
//    if (cnt !=0 && index != cnt) {
        [self resetSerialAfterInsertMenu:index];
        [self sortAllMenuAnimated:animated];
//    }
    
    
    MenuUIModel* aMenu=[[MenuUIModel alloc]init];
    aMenu.menuData = menuData;
    aMenu.menuData.serial = index;
    aMenu.menuTitlePosition =self.titlePosition;
    aMenu.deleteButtonIconName = self.deleteButtonIconName;
    aMenu.delegate=self;
    aMenu.frame=CGRectMake(0, 0, self.elementSize.width, self.elementSize.height);
    aMenu.center=[self getMenuCenter:(int)aMenu.menuData.serial];
    if (_enableEdit) {
        UILongPressGestureRecognizer* longPress=[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(handleLongPress:)];
        longPress.delegate=self;
        [aMenu addGestureRecognizer:longPress];
        
    }

    [self addSubview:aMenu];
    
}
- (void)displayGridWithTotalCount:(NSUInteger)count
{
    gridCount = count;
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect
{
    if (gridCount == 0) return;
    
    CGSize gridSize = [self gridForIndex:0].size;
    
    CGContextRef context = UIGraphicsGetCurrentContext();

    int row = gridCount % (_matrix.row * _matrix.column) / _matrix.column;
    int col = gridCount % (_matrix.row * _matrix.column) % _matrix.column;
    
    int nLine = row;
//    int nLine = (row == _matrix.row-1) ? row-1 : row;
    for (int i=0; i<nLine; ++i) {
        
        CGContextMoveToPoint(context, (int)(self.contentInset.left), (int)(self.contentInset.top + (i+1)* gridSize.height));
        CGContextAddLineToPoint(context, (int)(self.bounds.size.width - self.contentInset.left -self.contentInset.right), (int)(self.contentInset.top + (i+1)* gridSize.height));
    }
    if (col > 0) {
//    if (col > 0 && row + 1 < _matrix.row) {
        
        CGContextMoveToPoint(context, (int)(self.contentInset.left), (int)(self.contentInset.top + (row+1)* gridSize.height-1));
        CGContextAddLineToPoint(context, (int)(self.contentInset.left + col * gridSize.width), (int)(self.contentInset.top + (row+1)* gridSize.height-1));
    }
    
  
    if (col > 0) {
        
        for (int i=0; i<col; ++i) {
            
            CGContextMoveToPoint(context, self.contentInset.left + (i+1)* gridSize.width, self.contentInset.top + 1);
            CGContextAddLineToPoint(context, self.contentInset.left + (i+1)* gridSize.width, (row+1)* gridSize.height + self.contentInset.top);
        }
        for (int i=col; i<_matrix.column-1; ++i) {
            
            CGContextMoveToPoint(context, self.contentInset.left + (i+1)* gridSize.width, self.contentInset.top);
            CGContextAddLineToPoint(context, self.contentInset.left + (i+1)* gridSize.width, row* gridSize.height + self.contentInset.top);
        }
    }else {
        
        for (int i=0; i<_matrix.column-1; ++i) {
            
            CGContextMoveToPoint(context, self.contentInset.left + (i+1)* gridSize.width, self.contentInset.top);
            CGContextAddLineToPoint(context, self.contentInset.left + (i+1)* gridSize.width, row* gridSize.height + self.contentInset.top);
        }
    }

    CGContextSetStrokeColorWithColor(context, [[UIColor colorWithRed:220./255. green:220./255. blue:220./255. alpha:1.0] CGColor]);
    CGContextSetLineCap(context, kCGLineCapRound);
    CGContextSetLineWidth(context, 1.0);

    CGContextStrokePath(context);

}





- (void)removeMenuWithUid:(NSString *)uid animated:(BOOL)animated
{
    MenuUIModel *model =[self findMenuWithUid:uid];
    if (model) {
        [self removeMenu:model animated:animated];
        [self resetSerialAfterDeleteMenu:model.menuData.serial];
        [self sortAllMenuAnimated:animated];
    }
}
-(void)layoutSubviews
{
    [super layoutSubviews];
    self.scrollEnabled=YES;
    CGFloat w=self.bounds.size.width;
    CGFloat h=self.bounds.size.height;
    
    NSUInteger total=[self numberOfMenus];
    
    if (self.multiplyAllwaysOnTail) {
        [self awakenMultiplication:total];
        ++total;
    }
    self.contentSize= CGSizeMake((int)(w*(ceilingf(1.0*total/(_matrix.row * _matrix.column)))), (int)h);
}
-(void)resetSerialAfterDeleteMenu:(NSInteger)serial{
    for (UIView*v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            if (((MenuUIModel*)v).menuData.serial>serial) {
                ((MenuUIModel*)v).menuData.serial--;
            }
        }
    }
}
-(void)resetSerialAfterInsertMenu:(NSInteger)serial{
    for (UIView*v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            if (((MenuUIModel*)v).menuData.serial>=serial) {
                ((MenuUIModel*)v).menuData.serial++;
            }
        }
    }
}

- (void)clearup
{
    for (UIView*v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            if (v == multiplicationMenu) {
                multiplicationMenu.menuData.serial = 0;
                v.center = [self getMenuCenter:0];
            }else {
                [v removeFromSuperview];
            }
        }
    }
}

#pragma mark ----------click and delete

- (void)removeMenu:(MenuUIModel *)menu animated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.2 animations:^{
            menu.alpha=0.2;
            menu.transform=CGAffineTransformMakeScale(0.2, 0.2);
        }completion:^(BOOL finished) {
            [menu removeFromSuperview];
        }];
    }else {
        [menu removeFromSuperview];
    }
}

- (void)clickDeleteButtonOnMenu:(MenuUIModel *)model
{
    if ([menuDelegate respondsToSelector:@selector(menuView:shouldRemoveMenu:atIndex:)]) {
        BOOL shouldDelete=[menuDelegate menuView:self shouldRemoveMenu:model.menuData atIndex:model.menuData.serial];
        if (!shouldDelete) return;
    }
    [self removeMenu:model animated:YES];
    [self resetSerialAfterDeleteMenu:model.menuData.serial];
    [self sortAllMenuAnimated:YES];
    
    if (menuDelegate && [menuDelegate respondsToSelector:@selector(menuView:removedMenu:atIndex:)]) {
        [menuDelegate menuView:self removedMenu:model.menuData atIndex:model.menuData.serial];
    }
}
-(void)clickOnMenu:(MenuUIModel *)model
{
    if (multiplicationMenu && multiplicationMenu == model) {
        multiplicationMenu.menuData.icon = _multiplyIconName;
        if (menuDelegate && [menuDelegate respondsToSelector:@selector(menuView:clickedMultiplicationMenu:)]) {
            [menuDelegate menuView:self clickedMultiplicationMenu:model.menuData.serial];
        }
        
    }else{
        if ([menuDelegate respondsToSelector:@selector(menuView:clickedMenu:atIndex:)]) {
            [menuDelegate menuView:self clickedMenu:model.menuData atIndex:model.menuData.serial];
        }
    }
}


#pragma mark ----------tap and long press

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]]) {
        if (touch.view==self) {
            return YES;
        }else{
            return NO;
        }
    }
    return YES;
}
-(void)addTapGesture
{
    tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTap:)];
    tap.delegate=self;
    [self addGestureRecognizer:tap];

}
-(void)handleLongPress:(UILongPressGestureRecognizer *)gesture{
    
//    if (multiplicationMenu != nil) return;

    if (gesture.state==UIGestureRecognizerStateBegan) {
        current=[self areaContainsPoint:[gesture locationInView:self]]; 
        
        for (UIView*v in [self subviews]) {
            if ([v isKindOfClass:[MenuUIModel class]]) {
                MenuUIModel*menu =(MenuUIModel*)v;

                 if (menu.menuData.serial == current || menu.menuData == multiplicationMenu.menuData) {
                     menu.menuData.active = NO;
                     if (menu.menuData.serial == current) {
                         currentMenu=menu;
                     }
                 }else {
                     menu.menuData.active = YES;
                     
                 }
                [menu refresh];
            }
        }
        self.scrollEnabled=NO;
        _isEditing = YES;
        
        loc0=[gesture locationInView:self];
        previous=loc0;
        
    }
    if (gesture.state==UIGestureRecognizerStateChanged) {
        
        CGPoint loc=[gesture locationInView:self]; 
        
        currentMenu.center= CGPointMake(loc.x-previous.x+currentMenu.center.x, loc.y-previous.y+currentMenu.center.y);
        
        previous=loc;
    }
    
    if (gesture.state==UIGestureRecognizerStateEnded) {
        currentMenu.menuData.active=YES;
        [currentMenu refresh];
        
        self.scrollEnabled=YES;
        
        
        if (!CGPointEqualToPoint(previous, loc0)) {
            [self resetSerialAfterMoveMenu:currentMenu];
            [self sortAllMenuAnimated:YES];
        }
        
//        NSUInteger area=[self areaContainsPoint:currentMenu.center];
//        NSUInteger total=[self numberOfMenus];
//        if (area >= total) {
//            if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(menuView:moveMenuToTail:)]) {
//                
//                [self.menuDelegate menuView:self moveMenuToTail:currentMenu.menuData];
//            }
//        }else {
////            if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(menuView:exchangeMenu:withMenuAtIndex:)]) {
////                
////                [self.menuDelegate menuView:self exchangeMenu:currentMenu.menuData withMenuAtIndex:current];
////            }
//        }
        if (self.menuDelegate && [self.menuDelegate respondsToSelector:@selector(menuView: orderDidChange:)]) {
            NSMutableArray *ma =[[NSMutableArray alloc]init];
            for (MenuUIModel* v in [self subviews]) {
                if ([v isKindOfClass:[MenuUIModel class]]) {
                    [ma addObject:v];
                }
            }
            [self.menuDelegate menuView:self orderDidChange:ma];
        }
        
        
        [self addTapGesture];
        
        if (!self.multiplyAllwaysOnTail) {

            CGPoint position=[gesture locationInView:self];
            NSInteger serl=[self areaContainsPoint:position];
            [self awakenMultiplication:serl];
        } 
    }
}

-(void)awakenMultiplication:(NSInteger)fromIndex
{
    if (!_enableMultiply || multiplicationMenu != nil) return;
    
//    NSInteger total=[self numberOfMenus];
    
    multiplicationMenu=[[MenuUIModel alloc]init];
    MenuDataModel *data =[[MenuDataModel alloc]init];
    multiplicationMenu.frame=CGRectMake(0, 0, self.elementSize.width, self.elementSize.height);
    multiplicationMenu.menuTitlePosition = self.titlePosition;
    multiplicationMenu.delegate=self;
    multiplicationMenu.alpha=0.2;
    multiplicationMenu.transform=CGAffineTransformMakeScale(0.2, 0.2);
//    if (self.multiplyAllwaysOnTail) {
//        data.serial=total;
//        multiplicationMenu.center=[self getMenuCenter:total];
//    }else{
        data.serial=fromIndex;
        multiplicationMenu.center=[self getMenuCenter:fromIndex];
        [self resetSerialAfterInsertMenu:fromIndex];
        [self sortAllMenuAnimated:YES];
//    }
    data.icon= _multiplyIconName;
    multiplicationMenu.menuData = data;
    [self addSubview:multiplicationMenu];
    
    [UIView animateWithDuration:0.2 animations:^{
        
        multiplicationMenu.alpha=1.0;
        multiplicationMenu.transform=CGAffineTransformMakeScale(1.0, 1.0);
        
    }];

}

- (void)setIsEditing:(BOOL)isEditing
{
    _isEditing = isEditing;
    for (MenuUIModel* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            ((MenuUIModel*)v).menuData.active = _isEditing;
            [(MenuUIModel*)v refresh];
        }
    }
    if (!_isEditing) {
        [self endEditingAnimated:NO];
    }
}


-(void)endEditingAnimated:(BOOL)animated
{
    if (tap==nil) return;
//    CGPoint loc=CGPointMake(1.0, 1.0);
//    current=[self areaContainsPoint:loc];
    
    for (MenuUIModel* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            ((MenuUIModel*)v).menuData.active = NO;
            [(MenuUIModel*)v refresh];
        }
    }
    if (multiplicationMenu && _enableMultiply && !self.multiplyAllwaysOnTail) {

        [self removeMenu:multiplicationMenu animated:YES];
        
        [self resetSerialAfterDeleteMenu:multiplicationMenu.menuData.serial];
        [self sortAllMenuAnimated:animated];
        multiplicationMenu=nil;
        
    }

    [self removeGestureRecognizer:tap];
    tap = nil;

    if (menuDelegate && [menuDelegate respondsToSelector:@selector(menuView:didEndEditing:)]) {
        
        NSMutableArray *ma =[[NSMutableArray alloc]init];
        for (MenuUIModel* v in [self subviews]) {
            if ([v isKindOfClass:[MenuUIModel class]]) {
                [ma addObject:v];
            }
        }
        [menuDelegate menuView:self didEndEditing:ma];

    }
    _isEditing = NO;
}

-(void)handleTap:(UITapGestureRecognizer *)gesture
{
    [self endEditingAnimated:YES];
}
#pragma mark ----------persist save

- (MenuUIModel *)findMenuWithSerial:(NSUInteger)serial
{
    for (MenuUIModel* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            
            if (((MenuUIModel *)v).menuData.serial == serial) {
                return ((MenuUIModel *)v);
            }
        }
    }
    return nil;
}

- (MenuUIModel *)findMenuWithUid:(NSString *)uid
{
    for (MenuUIModel* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            
            if ([((MenuUIModel *)v).menuData.uid isEqualToString:uid]) {
                return ((MenuUIModel *)v);
            }
        }
    }
    return nil;
}
- (void)saveMenusToFile
{
    NSMutableArray *ret =[NSMutableArray array];
    
    NSString *path = FilePathInDoc(@"menuItems.plist");
    NSArray *ma =[[NSArray alloc]initWithContentsOfFile:path];
    NSUInteger num =[self numberOfMenus];
    int j=0;
    for (int i=0; i<ma.count; ++i) {
        
        NSMutableDictionary * menuDict =[NSMutableDictionary dictionaryWithDictionary:[ma objectAtIndex:i]];
        MenuDataModel *menu =[self findMenuWithUid:[menuDict objectForKey:@"uid"]].menuData;
        if (menu) {
            [menuDict setObject:[NSNumber numberWithBool:YES] forKey:@"display"];
            [menuDict setObject:[NSNumber numberWithInt:menu.serial] forKey:@"serial"];
            
        }else {
            [menuDict setObject:[NSNumber numberWithBool:NO] forKey:@"display"];
            [menuDict setObject:[NSNumber numberWithInt:num+j] forKey:@"serial"];
            ++j;
        }
        [ret addObject:menuDict];
    }
    
    [ret writeToFile:path atomically:YES];
    

}

- (void)saveMenusToFile2:(NSArray *)array
{    NSMutableArray *ma =[[NSMutableArray alloc]init];
    for (MenuUIModel* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {

            if (v == multiplicationMenu) {
                break;
            }
            NSMutableDictionary *md =[NSMutableDictionary dictionary];
            [md setObject:[NSNumber numberWithInt:v.menuData.serial] forKey:@"serial"];
//            [md setObject:[NSNumber numberWithInt:v.menuData.active] forKey:@"active"];
            [md setObject:[NSNumber numberWithInt:v.menuData.badge] forKey:@"badge"];
            [md setObject:[NSNumber numberWithInt:v.menuData.display] forKey:@"display"];
            if (v.menuData.title) {
                [md setObject:v.menuData.title forKey:@"title"];
            }
            if (v.menuData.uid) {
                [md setObject:v.menuData.uid forKey:@"uid"];
            }
            if (v.menuData.icon) {
                [md setObject:v.menuData.icon forKey:@"icon"];
            }
            if (v.menuData.icon2) {
                [md setObject:v.menuData.icon2 forKey:@"icon2"];
            }
            [ma addObject:md];
           
        }
    }

    
    NSString *path =FilePathInDoc(@"menuItems.plist");
    
    if (ma.count > 0) {

        [ma writeToFile:path atomically:YES];
    }else {
        [[NSFileManager defaultManager]removeItemAtPath:path error:nil];
    }
    
}
+ (NSArray *)readMenusFromFile
{
    NSString *path =FilePathInDoc(@"menuItems.plist");
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) return nil;
    NSArray *array =[[NSArray alloc]initWithContentsOfFile:path];
    if (array == nil || array.count ==0) return nil;
    
    NSMutableArray *ma =[NSMutableArray array];
    for (int i=0; i<array.count; ++i) {
        
        NSDictionary *dict =[array objectAtIndex:i];
        MenuDataModel *data =[[MenuDataModel alloc]initWithDictionary:dict];
        
        [ma addObject:data];
    }

    if (ma.count ==0) return nil;
    
    return ma;
}

#pragma mark ----------sort
NSComparisonResult compareSerial(NSDictionary *firstDict,NSDictionary *secondDict, void *context){
    if ([[firstDict objectForKey:@"serial"] intValue] < [[secondDict objectForKey:@"serial"] intValue])
        
        return NSOrderedAscending;
    
    else if ([[firstDict objectForKey:@"serial"] intValue] > [[secondDict objectForKey:@"serial"] intValue])
        
        return NSOrderedDescending;
    
    else
        
        return NSOrderedSame;
}

inline int ceilingf(float f)
{
    return f>(int)f?(int)f+1:(int)f;
}

-(NSUInteger)areaContainsPoint:(CGPoint)loc{
    CGFloat w=self.bounds.size.width;
    CGFloat h=self.bounds.size.height;
    int menuPerPage=(int)(loc.x/w)*(_matrix.row * _matrix.column);
    CGFloat xInPage=loc.x-(int)(loc.x/w)*w;
    int numInPage=(int)(loc.y/(h/_matrix.row))*_matrix.column+ceilingf((xInPage/(w/_matrix.column)));
    return menuPerPage+numInPage-1;
}

-(void)sortAllMenuAnimated:(BOOL)animated
{
    for (UIView* v in [self subviews]) {
        if ([v isKindOfClass:[MenuUIModel class]]) {
            int count=((MenuUIModel*)v).menuData.serial;
            
            CGPoint center=[self getMenuCenter:count];
            [UIView animateWithDuration:(animated?0.20:0) animations:^{
                v.center=center;
            }];
        }
    }
}

-(void)resetSerialAfterMoveMenu:(MenuUIModel *)menu{
    
    
    CGPoint loc=menu.center;
    NSUInteger area=[self areaContainsPoint:loc];
    NSLog(@"area:%d",area);
    NSUInteger total=[self numberOfMenus];
    NSLog(@"count:%d",total);
    
    if (area>=total) {
        
        for (UIView* v in [self subviews]) {
            if ([v isKindOfClass:[MenuUIModel class]]) {
                if (((MenuUIModel*)v).menuData.serial > menu.menuData.serial && ((MenuUIModel*)v).menuData.serial < total) {
                    
                    ((MenuUIModel*)v).menuData.serial--;
                }
            }
        }
        
        menu.menuData.serial=total-1;
        
    }else {
//        for (UIView* v in [self subviews]){
//            if ([v isKindOfClass:[MenuUIModel class]]) {
//                
//                if (((MenuUIModel*)v).menuData.serial == area) {
//                    ((MenuUIModel*)v).menuData.serial = menu.menuData.serial;
//                    menu.menuData.serial = area;
//
//                    break;
//                }
//            }
//            
//        }
        
// modify sort
        for (MenuUIModel* v in [self subviews]){
            if ([v isKindOfClass:[MenuUIModel class]]) {
                if (v.menuData.serial > menu.menuData.serial && v.menuData.serial < total) {
                    v.menuData.serial--;
                }
            }
        }
        
        for (MenuUIModel* v in [self subviews]){
            if ([v isKindOfClass:[MenuUIModel class]]) {
                if (v.menuData.serial >= area && v.menuData.serial < total && v != menu) {
                    v.menuData.serial++;
                }
            }
        }
        menu.menuData.serial = area;
    }
#ifndef __OPTIMIZE__
    if (0) {
        for (UIView* v in [self subviews]) {
            if ([v isKindOfClass:[MenuUIModel class]]) {
                NSLog(@"%@---%d",((MenuUIModel*)v).menuData.title,((MenuUIModel*)v).menuData.serial);
                
            }
        }
    }
#endif
}

- (void)enumerateItemsUsingBlock:(void (^)(MenuUIModel *, BOOL *))enumerateBlock
{
    BOOL stop = NO;
    for (int i=0; i< [self numberOfMenus]; ++i) {
        MenuUIModel *model =[self findMenuWithSerial:i];
        if (stop) {
            break;
        }
        enumerateBlock(model,&stop);
        
    }
}
- (void)dealloc
{
    _allMenus = nil;
    self.delegate = nil;
    self.menuDelegate = nil;
    self.multiplyIconName = nil;
}
@end
