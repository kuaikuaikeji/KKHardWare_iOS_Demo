//
//  KKUser.h
//  OCExample
//
//  Created by 岳坤 on 2020/8/3.
//  Copyright © 2020 KuaiKuaiLeDong. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface KKUser : NSObject

+ (instancetype)shared;

@property (assign, nonatomic) NSInteger height;

@property (assign, nonatomic) NSInteger weight;

@property (assign, nonatomic) NSInteger age;

@property (assign, nonatomic) NSInteger sex;

@property (assign, nonatomic) NSInteger heartRate;

@end

NS_ASSUME_NONNULL_END
