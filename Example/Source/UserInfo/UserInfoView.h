//
//  UserInfoView.h
//  OCExample
//
//  Created by 岳坤 on 2020/8/3.
//  Copyright © 2020 KuaiKuaiLiHua. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UserInfoView : UIView

+ (void)showInView:(UIView *)view sureCallback:(void(^)(void))callback;

@end

NS_ASSUME_NONNULL_END
