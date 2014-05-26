//
//  MenuDataModel.h
//  menu
//
//  Created by yuangongji on 14-6-16.
//  Copyright (c) 2014 yuangongji. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MenuDataModel : NSObject

@property(nonatomic)NSUInteger serial;
@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *uid;
@property(nonatomic, copy)NSString *icon;
@property(nonatomic, copy)NSString *icon2;
@property(nonatomic)NSUInteger badge;
@property(nonatomic)BOOL active;
@property(nonatomic)BOOL display;

/*
 Args：
 serial     :   NSNumber
 active     :   NSNumber
 badge      :   NSNumber
 display    :   NSNumber
 title      :   NSString
 uid        :   NSString
 icon       :   NSString
 icon2      :   NSString
 */

- (id)initWithDictionary:(NSDictionary *)dict;
- (id)initWithTitle:(NSString *)title uid:(NSString *)uid icon:(NSString *)icon;
+ (id)dataModelWithTitle:(NSString *)title uid:(NSString *)uid icon:(NSString *)icon;
@end
