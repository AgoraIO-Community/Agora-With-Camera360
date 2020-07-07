//
//  KeyCenter.m
//  OpenLive
//
//  Created by GongYuhua on 2016/9/12.
//  Copyright © 2016年 Agora. All rights reserved.
//

#import "KeyCenter.h"

@implementation KeyCenter
+ (NSString *)AppId {
    return @"7db05f7d569847a995cdda5a02e9a319";
}

// assign token to nil if you have not enabled app certificate
+ (NSString *)Token {
    return nil;
}
@end
