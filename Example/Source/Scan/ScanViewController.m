//
//  ScanViewController.m
//  OCExample
//
//  Created by YueKun on 2020/7/8.
//  Copyright © 2020 KuaiKuaiLiHua. All rights reserved.
//

#import "ScanViewController.h"
#import <KKBLEPeripheralSDK/KKBLEPeripheralSDK-Swift.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import "ArmBandViewController.h"
#import "HealthScaleViewController.h"

@interface ScanViewController ()<KKBLECentralManagerDelegate, UITableViewDelegate, UITableViewDataSource>

/// 中央管理器
@property (strong, nonatomic) KKBLECentralManager *centralManager;

/// 外设列表
@property (strong, nonatomic) NSMutableArray *peripherals;

/// TableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 正在连接的外设
@property (strong, nonatomic) id<KKPeripheral>  selectedPeripheral;

/// 是否开始扫描
@property (assign, nonatomic) BOOL isStartScan;

@end

@implementation ScanViewController

+ (instancetype)initFromStoryboard {
    ScanViewController *instance = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ScanViewController"];
    return  instance;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.isStartScan) {
        [self checkCentralState];
    }
}

- (NSMutableArray *)peripherals {
    if (_peripherals == nil) {
        _peripherals = [NSMutableArray array];
    }
    return _peripherals;
}

# pragma mark - Action

- (IBAction)scanClick:(UIButton *)sender {
    if (self.isStartScan) {
        [self stopAndReload];
    }
    
    self.isStartScan = YES;

    [self checkCentralState];
}

- (void)stopAndReload {
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
    [self.centralManager stopScan];
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
            if (self.isStartScan) {
                [self.centralManager scanWithPeripheralTypes:@[@(KKPeripheralTypeArmBand), @(KKPeripheralTypeHealthScale)]];
            }
            break;
    }
}

# pragma mark - KKBLECentralManager

- (KKBLECentralManager *)centralManager {
    if (_centralManager == nil) {
        _centralManager = [[KKBLECentralManager alloc] init];
        _centralManager.delegate = self;
    }
    return _centralManager;
}

/// 中央状态发生变化
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didUpdateState:(enum KKBLECentralState)state {
    [self checkCentralState];
}

/// 发现外设
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didDiscover:(id<KKPeripheral> _Nonnull)peripheral rssi:(NSNumber * _Nonnull)RSSI {
    [self.peripherals addObject:peripheral];
    [self.tableView reloadData];
}

/// 外设连接成功
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didConnect:(id<KKPeripheral> _Nonnull)peripheral {
    if (self.selectedPeripheral && [peripheral.mac isEqualToString:self.selectedPeripheral.mac]) {
        self.selectedPeripheral = nil;
        [SVProgressHUD showSuccessWithStatus:@"连接成功"];
        [SVProgressHUD dismissWithDelay:2.0];
        switch (peripheral.type) {
            case KKPeripheralTypeArmBand:
                [self performSelector:@selector(navigateToArmBand:) withObject:peripheral.mac afterDelay:2.0];
                break;
            case KKPeripheralTypeHealthScale:
                [self performSelector:@selector(navigateToHealthScale:) withObject:peripheral.mac afterDelay:2.0];
                break;
        }
    }
}

/// 外设连接失败
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didFailToConnect:(id<KKPeripheral> _Nonnull)peripheral error:(NSError * _Nullable)error {
    if (self.selectedPeripheral && [peripheral.mac isEqualToString:self.selectedPeripheral.mac]) {
        self.selectedPeripheral = nil;
        [SVProgressHUD showErrorWithStatus:@"连接失败，请重新连接..."];
        [SVProgressHUD dismissWithDelay:1.0];
    }
}

/// 外设断开连接
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didDisconnectPeripheral:(id<KKPeripheral> _Nonnull)peripheral error:(NSError * _Nullable)error {
    if (self.selectedPeripheral && [peripheral.mac isEqualToString:self.selectedPeripheral.mac]) {
        self.selectedPeripheral = nil;
        [SVProgressHUD showErrorWithStatus:@"连接断开，请重新连接..."];
        [SVProgressHUD dismissWithDelay:1.0];
    }
    
}

# pragma mark - UITableView

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.peripherals.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"ScanIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell  alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    
    if (indexPath.row < self.peripherals.count) {
        id<KKPeripheral> peripheral = [self.peripherals objectAtIndex:indexPath.row];
        cell.textLabel.text = peripheral.name;
        cell.detailTextLabel.text = peripheral.mac;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return  cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.peripherals.count) {
        [SVProgressHUD showWithStatus:@"正在连接..."];
        id<KKPeripheral> peripheral = [self.peripherals objectAtIndex:indexPath.row];
        self.selectedPeripheral = peripheral;
        [self.centralManager connectWithPeripheral:peripheral timeout:20.0];
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

- (void)navigateToArmBand:(NSString *)mac {
    ArmBandViewController *controller = [ArmBandViewController initWithMac:mac];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)navigateToHealthScale:(NSString *)mac {
    HealthScaleViewController *controller = [HealthScaleViewController initWithMac:mac];
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [self.centralManager  stopScan];
    // 移除数据
    [self.peripherals removeAllObjects];
    [self.tableView reloadData];
}

@end
