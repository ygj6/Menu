//
//  MenuDataModel.m
//  menu
//
//  Created by yuangongji on 14-6-16.
//  Copyright (c) 2014 yuangongji. All rights reserved.
//

#import "MenuDataModel.h"

@implementation MenuDataModel

- (id)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        
        self.serial =[[dict objectForKey:@"serial"] integerValue];
//        self.active =[[dict objectForKey:@"active"] boolValue];
        
        self.badge =[[dict objectForKey:@"badge"] integerValue];
        self.display =[[dict objectForKey:@"display"] boolValue];
        
        self.title = [dict objectForKey:@"title"];
        self.uid = [dict objectForKey:@"uid"];
        self.icon = [dict objectForKey:@"icon"];
        self.icon2 = [dict objectForKey:@"icon2"];
    }
    return self;
}
- (id)initWithTitle:(NSString *)title uid:(NSString *)uid icon:(NSString *)icon
{
    self = [super init];
    if (self) {
        self.title = title;
        self.uid = uid;
        self.icon = icon;
    }
    return self;
}
+ (id)dataModelWithTitle:(NSString *)title uid:(NSString *)uid icon:(NSString *)icon
{
    return [[self alloc] initWithTitle:title uid:uid icon:icon];
}

- (void)dealloc
{
    self.title = nil;
    self.uid =nil;
    self.icon =nil;
    self.icon2 =nil;
//    [super dealloc];
}
@end
