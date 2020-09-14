//
//  AppDelegate.m
//  Example
//
//  Created by 岳坤 on 2020/9/10.
//  Copyright © 2020 岳坤. All rights reserved.
//

#import "AppDelegate.h"
#import <KKBLEPeripheralSDK/KKBLEPeripheralSDK-Swift.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "KKUser.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
        
    // 注册App
    [KKBLEPeripheralAPI registerWithAppID:@"b583ba40-09d3-4b41-9cde-606975ae5600" callBack:^(BOOL result) {
    }];
    
    // 设置默认数据
    KKUser.shared.height = 170;
    KKUser.shared.weight = 70;
    KKUser.shared.age = 30;
    KKUser.shared.sex = 0;
    KKUser.shared.heartRate = 60;

    // HUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setMinimumSize:CGSizeMake(200.0, 120.0)];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    return YES;
}

@end
