//
//  UserInfoView.m
//  OCExample
//
//  Created by 岳坤 on 2020/8/3.
//  Copyright © 2020 KuaiKuaiLiHua. All rights reserved.
//

#import "UserInfoView.h"
#import "KKUser.h"
#import <ActionSheetPicker.h>

@interface UserInfoView ()

@property (weak, nonatomic) IBOutlet UIButton *heightButton;
@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UIButton *heartRateButton;


@property (assign, nonatomic) NSInteger height;

@property (assign, nonatomic) NSInteger weight;

@property (assign, nonatomic) NSInteger age;

@property (assign, nonatomic) NSInteger sex;

@property (assign, nonatomic) NSInteger heartRate;

@property (copy, nonatomic) void(^sureCallback)(void);

@end

@implementation UserInfoView


+ (void)showInView:(UIView *)view sureCallback:(void(^)(void))callback {
    UserInfoView *infoView = [[[NSBundle mainBundle] loadNibNamed:@"UserInfoView" owner:nil options:nil] firstObject];
    infoView.frame = view.bounds;
    infoView.sureCallback = callback;
    [view addSubview:infoView];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    
    self.height = KKUser.shared.height;
    [self.heightButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.height] forState:UIControlStateNormal];
    
    self.weight = KKUser.shared.weight;
    [self.weightButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.weight] forState:UIControlStateNormal];
    
    self.age = KKUser.shared.age;
    [self.ageButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.age] forState:UIControlStateNormal];

    self.sex = KKUser.shared.sex;
    NSString *sexTitile = (self.sex == 0) ? @"男" : @"女";
    [self.sexButton setTitle:sexTitile forState:UIControlStateNormal];
    
    self.heartRate = KKUser.shared.heartRate;
    [self.heartRateButton setTitle:[NSString stringWithFormat:@"%ld", (long)self.heartRate] forState:UIControlStateNormal];
}

- (IBAction)heightClick:(UIButton *)sender {
    // 90 ~ 220cm
    NSMutableArray *rows = [NSMutableArray array];
    NSInteger index = 0;
    for (int i = 90; i <= 220; i++) {
        [rows addObject:[NSString stringWithFormat:@"%d", i]];
        if (i == self.height) {
            index = i - 90;
        }
    }
    [ActionSheetStringPicker showPickerWithTitle:@"请选择身高（cm）" rows:rows initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.height = [selectedValue integerValue];
        [sender setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:nil origin:nil];
}

- (IBAction)weightClick:(UIButton *)sender {
    // 10  ~ 200kg
    NSMutableArray *rows = [NSMutableArray array];
    NSInteger index = 0;
    for (int i = 10; i <= 200; i++) {
        [rows addObject:[NSString stringWithFormat:@"%d", i]];
        if (i == self.weight) {
            index = i - 10;
        }
    }
    [ActionSheetStringPicker showPickerWithTitle:@"请选择体重（kg）" rows:rows initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.weight = [selectedValue integerValue];
        [sender setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:nil origin:nil];
}

- (IBAction)ageClick:(UIButton *)sender {
    // 6 ~ 99岁
    NSMutableArray *rows = [NSMutableArray array];
    NSInteger index = 0;
    for (int i = 6; i <= 99; i++) {
        [rows addObject:[NSString stringWithFormat:@"%d", i]];
        if (i == self.age) {
            index = i - 6;
        }
    }
    [ActionSheetStringPicker showPickerWithTitle:@"请选择年龄" rows:rows initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.age = [selectedValue integerValue];
        [sender setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:nil origin:nil];
}

- (IBAction)sexClick:(UIButton *)sender {
    NSArray *rows = @[@"男", @"女"];
    NSInteger index = [rows indexOfObject:sender.titleLabel.text];
    [ActionSheetStringPicker showPickerWithTitle:@"请选择性别" rows:rows initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        if ([selectedValue isEqualToString:@"男"]) {
            self.sex = 0;
        } else {
            self.sex = 1;
        }
        [sender setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:nil origin:nil];
}

- (IBAction)heartRateClick:(UIButton *)sender {
    NSMutableArray *rows = [NSMutableArray array];
    NSInteger index = 0;
    for (int i = 30; i <= 100; i++) {
        [rows addObject:[NSString stringWithFormat:@"%d", i]];
        if (i == self.heartRate) {
            index = i - 30;
        }
    }
    [ActionSheetStringPicker showPickerWithTitle:@"请选择静态心率" rows:rows initialSelection:index doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        self.heartRate = [selectedValue integerValue];
        [sender setTitle:selectedValue forState:UIControlStateNormal];
    } cancelBlock:nil origin:nil];
}

- (IBAction)closeClick:(UIButton *)sender {
    [self removeFromSuperview];
}

- (IBAction)sureClick:(UIButton *)sender {
    if (self.sureCallback) {
        KKUser.shared.height = self.height;
        KKUser.shared.weight = self.weight;
        KKUser.shared.age = self.age;
        KKUser.shared.sex = self.sex;
        KKUser.shared.heartRate = self.heartRate;
        [self removeFromSuperview];
        self.sureCallback();
    }
}

@end
