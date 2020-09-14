//
//  KKUser.m
//  OCExample
//
//  Created by 岳坤 on 2020/8/3.
//  Copyright © 2020 KuaiKuaiLiHua. All rights reserved.
//

#import "KKUser.h"

@implementation KKUser


+ (instancetype)shared {
    static dispatch_once_t onceToken;
    static KKUser *instance;
    dispatch_once(&onceToken, ^{
        instance = [[KKUser alloc] init];
    });
    return instance;
}

@end
