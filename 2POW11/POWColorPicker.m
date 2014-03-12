//
//  POWColorPicker.m
//  2POW11
//
//  Created by Alexander Faxå on 12/03/14.
//  Copyright (c) 2014 Alexander Faxå. All rights reserved.
//

#import "POWColorPicker.h"

@implementation POWColorPicker

+ (UIColor *)colorWithR:(unsigned int)r G:(unsigned int)g B:(unsigned int)b {
    return [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0f];
}

+ (UIColor *)colorForNumber:(unsigned int)number {
    switch (number) {
        case 1:
            return [self colorWithR:239 G:201 B:201];
            break;
        case 2:
            return [self colorWithR:240 G:215 B:204];
            break;
        case 4:
            return [self colorWithR:241 G:231 B:204];
            break;
        case 8:
            return [self colorWithR:230 G:242 B:207];
            break;
        case 16:
            return [self colorWithR:208 G:242 B:212];
            break;
        case 32:
            return [self colorWithR:200 G:241 B:234];
            break;
        case 64:
            return [self colorWithR:194 G:224 B:238];
            break;
        case 128:
            return [self colorWithR:197 G:192 B:237];
            break;
        case 256:
            return [self colorWithR:231 G:161 B:220];
            break;
        case 512:
            return [self colorWithR:226 G:135 B:168];
            break;
        case 1024:
            return [self colorWithR:222 G:89 B:110];
            break;
        case 2048:
            return [self colorWithR:246 G:13 B:32];
            break;
        default:
            return [UIColor whiteColor];  // Error.
            break;
    }
}

@end
