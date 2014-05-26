//
//  common.h
//  menu
//
//  Created by yuangongji on 14-8-26.
//  Copyright (c) 2014 yuangongji. All rights reserved.
//

#ifndef xy_common_h
#define xy_common_h

typedef struct XYMatrix {
    
    NSUInteger row;
    NSUInteger column;
    
}XYMatrix;

static inline XYMatrix XYMatrixMake(NSUInteger _x, NSUInteger _y)
{
    return (XYMatrix){.row = (_x>0?_x:1), .column =(_y>0?_y:1)};
}
static inline bool XYMatrixEqualToMatrix(XYMatrix one, XYMatrix another)
{
    return one.row == another.row && one.column == another.column;
}

#endif
