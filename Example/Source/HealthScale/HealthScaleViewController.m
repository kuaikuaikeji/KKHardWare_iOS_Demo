//
//  HealthScaleViewController.m
//  OCExample
//
//  Created by YueKun on 2020/7/9.
//  Copyright © 2020 KuaiKuaiLeDong. All rights reserved.
//

#import "HealthScaleViewController.h"
#import <KKBLEPeripheralSDK/KKBLEPeripheralSDK-Swift.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "KKUser.h"
#import "UserInfoView.h"

@interface HealthScaleViewController ()<KKBLECentralManagerDelegate, KKBLEHealthScalePeripheralDelegate>

@property (strong, nonatomic) KKBLECentralManager *centralManager;

@property (assign, nonatomic) KKBLECentralState centralState;

@property (strong, nonatomic) KKBLEHealthScalePeripheral *peripheral;

/// 外设mac
@property (copy, nonatomic) NSString *peripheralMac;

@property (assign, nonatomic) BOOL isFinish;

@end

@implementation HealthScaleViewController

+ (instancetype)initWithMac:(NSString *)mac {
    HealthScaleViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"HealthScaleViewController"];
    controller.peripheralMac = mac;
    return  controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.centralManager.delegate = self;
    [UserInfoView showInView:self.view sureCallback:^{
        
    }];
}

# pragma mark - KKBLECentralManager

- (KKBLECentralManager *)centralManager {
    if (_centralManager == nil) {
        _centralManager = [[KKBLECentralManager alloc] init];
    }
    return _centralManager;
}

- (void)centralManager:(KKBLECentralManager * _Nonnull)central didUpdateState:(enum KKBLECentralState)state {
    [self checkCentralState];
}

- (void)centralManager:(KKBLECentralManager *)central didConnect:(id<KKPeripheral>)peripheral {
    if ([peripheral.mac isEqualToString:self.peripheralMac]) {
        [SVProgressHUD showWithStatus:@"正在测量..."];
        self.peripheral = (KKBLEHealthScalePeripheral *)peripheral;
        [self.peripheral appendDelegate:self];
        
        KKSexType sex = (KKUser.shared.sex == 0) ? KKSexTypeMale : KKSexTypeFemale;
        [self.peripheral readBodyDataWithUserUUID:@"123456" sex:sex age:KKUser.shared.age height:KKUser.shared.height];
    }
}

- (void)centralManager:(KKBLECentralManager *)central didFailToConnect:(id<KKPeripheral>)peripheral error:(NSError *)error {
    if ([peripheral.mac isEqualToString:self.peripheralMac] && !self.isFinish) {
        [SVProgressHUD showErrorWithStatus:@"连接失败，请重新测量"];
        [SVProgressHUD dismissWithDelay:2.0];
    }
}

- (void)centralManager:(KKBLECentralManager *)central didDisconnectPeripheral:(id<KKPeripheral>)peripheral error:(NSError *)error {
    if ([peripheral.mac isEqualToString:self.peripheralMac] && !self.isFinish) {
        [SVProgressHUD showErrorWithStatus:@"连接断开，请重新测量..."];
               [SVProgressHUD dismissWithDelay:2.0];
    }
}



# pragma mark - Action

- (IBAction)startClick:(UIButton *)sender {
    self.isFinish = NO;
    [self checkCentralState];
}

- (void)checkCentralState {
    switch (self.centralManager.state) {
        case KKBLECentralStateUnknown:
            break;
        case KKBLECentralStateResetting:
            break;
        case KKBLECentralStateUnsupported:
            break;
        case KKBLECentralStateUnauthorized:
            [self showAuthAlert];
            break;
        case KKBLECentralStatePoweredOff:
            [self showPowerOffAlert];
            break;
        case KKBLECentralStatePoweredOn:
            [SVProgressHUD showWithStatus:@"正在连接，请重新上称进行测量..."];
            self.peripheral = nil;
            [self.centralManager connectWithPeripheralType:KKPeripheralTypeHealthScale mac:self.peripheralMac timeout:20.0];
            break;
    }
}

- (IBAction)disconnectClick:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:true];
}

# pragma mark - HealthScale

/// 接收到身体数据
- (void)healthScalePeripheral:(KKBLEHealthScalePeripheral *)peripheral didReceiveBodyData:(KKHealthScaleBodyDataModel *)data errorType:(enum KKHealthScaleBodyDataErrorType)errorType {
    [SVProgressHUD dismiss];
    self.isFinish = YES;
    switch (errorType) {
        case KKHealthScaleBodyDataErrorTypeNone: {
            [self showSuccessAlert:data];
            break;
        }
        case KKHealthScaleBodyDataErrorTypeImpedance: {
            [self  showNormalAlertWithTitle:@"阻抗值有误，无法计算详细数据，请光脚上称" andMessage:[NSString stringWithFormat:@"体重：%.2f kg", data.weight]];
            break;
        }
        case KKHealthScaleBodyDataErrorTypeAge: {
            [self  showNormalAlertWithTitle:@"年龄输入有误有误，无法计算详细数据" andMessage:[NSString stringWithFormat:@"体重：%.2f kg", data.weight]];
            break;
        }
        case KKHealthScaleBodyDataErrorTypeWeight: {
            [self showNormalAlertWithTitle:@"体重超标，无法计算详细数据" andMessage:[NSString stringWithFormat:@"体重：%.2f kg", data.weight]];
            break;
        }
        case KKHealthScaleBodyDataErrorTypeHeight: {
            [self showNormalAlertWithTitle:@"身高输入有误，无法计算详细数据" andMessage:[NSString stringWithFormat:@"体重：%.2f kg", data.weight]];
            break;
        }
    }
}

/// 接收到报告数据
- (void)healthScalePeripheral:(KKBLEHealthScalePeripheral *)peripheral didReceiveReportData:(NSString *)data errorType:(enum KKHealthScaleReportDataErrorType)errorType {
    switch (errorType) {
        case KKHealthScaleReportDataErrorTypeNone:
            [self  showNormalAlertWithTitle:@"报告数据" andMessage: data];
            break;
        case KKHealthScaleReportDataErrorTypeNet:
            [SVProgressHUD showErrorWithStatus:@"网络异常..."];
            [SVProgressHUD dismissWithDelay:2.0];
            break;
    }
}

# pragma mark - Other

- (void)showAuthAlert {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"蓝牙权限不可用，请打开蓝牙权限" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [controller addAction:sure];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showPowerOffAlert {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"蓝牙不可用，请打开蓝牙" message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }];
    [controller addAction:sure];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showSuccessAlert:(KKHealthScaleBodyDataModel *)data {
    
    NSMutableArray *datas = [NSMutableArray array];
    
    [datas addObject:[NSString  stringWithFormat:@"体重：%.2f kg", data.weight]];
    [datas addObject:[NSString  stringWithFormat:@"身体年龄：%ld", (long)data.bodyAge]];
    [datas addObject:[NSString  stringWithFormat:@"身体得分：%ld", (long)data.bodyScore]];
    [datas addObject:[NSString  stringWithFormat:@"理想体重：%.2f kg", data.idealWeight]];
    [datas addObject:[NSString  stringWithFormat:@"标准体重：%.2f kg", data.standardWeight]];
    [datas addObject:[NSString  stringWithFormat:@"去脂体重：%.2f kg", data.loseFatWeight]];
    [datas addObject:[NSString  stringWithFormat:@"控制体重：%.2f kg", data.controlWeight]];
    [datas addObject:[NSString  stringWithFormat:@"bmi：%.2f", data.bmi]];
    [datas addObject:[NSString  stringWithFormat:@"bmr：%.2ld", (long)data.bmr]];
    [datas addObject:[NSString  stringWithFormat:@"蛋白质率：%.2f%%", data.proteinPercentage]];
    [datas addObject:[NSString  stringWithFormat:@"vfal：%ld", (long)data.vfal]];
    [datas addObject:[NSString  stringWithFormat:@"骨量：%.2f kg", data.boneWeight]];
    [datas addObject:[NSString  stringWithFormat:@"脂肪量：%.2f kg", data.fatWeight]];
    [datas addObject:[NSString  stringWithFormat:@"脂肪率：%.2f%%", data.fatPercentage]];
    [datas addObject:[NSString  stringWithFormat:@"脂肪控制量：%.2f kg", data.fatControlWeight]];
    [datas addObject:[NSString  stringWithFormat:@"皮下脂肪：%.2f%%", data.subcutaneousFatPercentage]];
    [datas addObject:[NSString  stringWithFormat:@"水分率：%.2f%%", data.waterPercentage]];
    [datas addObject:[NSString  stringWithFormat:@"肌肉量：%.2f kg", data.muscleWeight]];
    [datas addObject:[NSString  stringWithFormat:@"肌肉率：%.2f%%", data.musclePercentage]];
    [datas addObject:[NSString  stringWithFormat:@"肌肉控制量：%.2f kg", data.muscleControlWeight]];
    [datas addObject:[NSString  stringWithFormat:@"骨骼肌率：%.2f%%", data.skeletalPercentage]];
    
    NSString *message = [datas componentsJoinedByString:@"\n"];
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"测量成功" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    [controller addAction:cancelAction];
    
    UIAlertAction *reportAction = [UIAlertAction actionWithTitle:@"查看报告" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.peripheral readBodyReport];
    }];
    [controller addAction:reportAction];

    [self presentViewController:controller animated:YES completion:nil];
}

- (void)showNormalAlertWithTitle:(NSString *)title andMessage:(NSString  *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [controller addAction:sure];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)dealloc {
    [self.centralManager cancelConnectWithPeripheralType:KKPeripheralTypeHealthScale mac:self.peripheralMac];
    NSLog(@"HealthScaleViewController dealloc");
}

@end
