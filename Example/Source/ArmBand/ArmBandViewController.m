//
//  ArmBandViewController.m
//  OCExample
//
//  Created by YueKun on 2020/7/8.
//  Copyright © 2020 KuaiKuaiLeDong. All rights reserved.
//

#import "ArmBandViewController.h"
#import <KKBLEPeripheralSDK/KKBLEPeripheralSDK-Swift.h>
#import "ArmBandTableViewCell.h"
#import "UserInfoView.h"
#import "KKUser.h"

@interface ArmBandViewController ()<KKBLECentralManagerDelegate, KKBLEArmBandPeripheralDelegate, KKBLEPeripheralDFUManagerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// 外设mac
@property (copy, nonatomic) NSString *peripheralMac;

/// 中心管理器
@property (strong, nonatomic) KKBLECentralManager *centralManager;

/// 臂带外设
@property (strong, nonatomic) KKBLEArmBandPeripheral *peripheral;

/// 消息
@property (strong, nonatomic) NSMutableArray *messages;

/// 是否在升级
@property (assign, nonatomic) BOOL isDFU;

/// 是否在滑动
@property (assign, nonatomic) BOOL isScroll;

/// DFU管理器
@property (strong, nonatomic) KKBLEPeripheralDFUManager *dfuManager;


@property (assign, nonatomic) NSInteger currentCal;

@end

@implementation ArmBandViewController


+ (instancetype)initWithMac:(NSString *)mac {
    ArmBandViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"ArmBandViewController"];
    controller.peripheralMac = mac;
    return  controller;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initTableView];
    [self connectPeripheral];
    
    [UserInfoView showInView:self.view sureCallback:^{
        [self setUseInfo];
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)initTableView {
    [self.tableView registerNib:[UINib nibWithNibName:@"ArmBandTableViewCell" bundle:nil] forCellReuseIdentifier:@"ArmBandTableViewCell"];
}

- (NSMutableArray *)messages {
    if (_messages == nil) {
        _messages = [NSMutableArray array];
    }
    return _messages;
}

# pragma mark - KKBLECentralManagerDelegate

/// 中央管理器
- (KKBLECentralManager *)centralManager {
    if (_centralManager == nil) {
        _centralManager = [[KKBLECentralManager alloc] init];
        _centralManager.delegate = self;
    }
    return _centralManager;
}

/// 中央状态发生变化
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didUpdateState:(enum KKBLECentralState)state {
    switch (state) {
        case KKBLECentralStateUnknown:
            break;
        case KKBLECentralStateResetting:
            break;
        case KKBLECentralStateUnsupported:
            break;
        case KKBLECentralStateUnauthorized:
            break;
        case KKBLECentralStatePoweredOff:
            break;
        case KKBLECentralStatePoweredOn:
            [self connectPeripheral];
            break;
    }
}

/// 外设连接成功
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didConnect:(id<KKPeripheral> _Nonnull)peripheral {
    [self addMessage:@"连接成功"];
    self.peripheral = (KKBLEArmBandPeripheral *)peripheral;
    [self.peripheral appendDelegate:self];
}

/// 外设连接失败
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didFailToConnect:(id<KKPeripheral> _Nonnull)peripheral error:(NSError * _Nullable)error {
    [self addMessage:@"连接失败"];
    if (!self.isDFU) {
        [self connectPeripheral];
    }
}

/// 外设断开连接
- (void)centralManager:(KKBLECentralManager * _Nonnull)central didDisconnectPeripheral:(id<KKPeripheral> _Nonnull)peripheral error:(NSError * _Nullable)error {
    [self addMessage:@"断开连接"];
    if (!self.isDFU) {
        [self connectPeripheral];
    }
}

# pragma mark - Action

- (IBAction)disconnectClick:(UIButton *)sender {
    if (self.peripheral) {
        [self.centralManager cancelConnectWithPeripheral:self.peripheral];
    }
    [self.navigationController popViewControllerAnimated:true];
}

- (IBAction)bindClick:(UIButton *)sender {
    [self addMessage:@"开始绑定，点击设备任意按键进行绑定确认。"];
    [self.peripheral bindWithTimeout:30.0];
}

- (IBAction)seekClick:(UIButton *)sender {
    [self addMessage:@"查找设备：目标设备正在震动..."];
    [self.peripheral seek];
}

- (void)setUseInfo {
    [self addMessage:@"开始设置用户信息..."];
    KKSexType sex = (KKUser.shared.sex == 0) ? KKSexTypeMale : KKSexTypeFemale;
    [self.peripheral setUserWithUserUUID:@"123456-789-100" sex:sex age:KKUser.shared.age height:KKUser.shared.height weight:KKUser.shared.weight pulse:KKUser.shared.heartRate];
}

- (IBAction)brightnessClick:(UIButton *)sender {
    [self addMessage:@"开始设亮度..."];
    [self.peripheral setBrightnessWithLevel:arc4random() % 11];
}

- (IBAction)syncTimeClick:(UIButton *)sender {
    [self addMessage:@"开始同步时间..."];
    [self.peripheral setTimeWithDate:[NSDate date]];
}

- (IBAction)startSportClick:(UIButton *)sender {
    [self addMessage:@"开始运动..."];
    [self.peripheral startSportWithSportType:KKPeripheralOnlineSportTypeIndoorRunning startMetronome:YES cadence:100 dataReturnCycle:0];
}

- (IBAction)sportDataClick:(UIButton *)sender {
    [self addMessage:@"正在获取心率数据（开始训练后才能获取到数据）"];
    [self.peripheral readSportDataWithCal:self.currentCal];
}

- (IBAction)stopSportClick:(UIButton *)sender {
    [self addMessage:@"停止运动..."];
    [self.peripheral stopSport];
}

- (IBAction)historyClick:(UIButton *)sender {
    [self addMessage:@"读取历史数据..."];
    [self.peripheral readHistoryData];
}

- (IBAction)versionClick:(UIButton *)sender {
    [self addMessage:@"开始读取版本信息..."];
    [self.peripheral readVersion];
}

- (IBAction)batteryClick:(UIButton *)sender {
    [self addMessage:@"开始读取电量..."];
    [self.peripheral readBattery];
}

- (IBAction)newVersionClick:(UIButton *)sender {
    if (!self.isDFU) {
        [self addMessage:@"开始检查新版本..."];
        [self.peripheral checkNewVersion];
    } else {
        [self showNormalAlertWithTitle:@"正在升级..." andMessage:nil];
    }
}

- (IBAction)oldVersionClick:(UIButton *)sender {
    if (!self.isDFU) {
        [self startDFU:@"https://kuaikuai.oss-cn-beijing.aliyuncs.com/upload/a0d3f9e5-79e5-4aa5-bacc-40108a5538b0.zip"];
    } else {
        [self showNormalAlertWithTitle:@"正在升级..." andMessage:nil];
    }
}

/// 连接外设
- (void)connectPeripheral {
    [self addMessage:@"开始连接..."];
    [self.centralManager connectWithPeripheralType:KKPeripheralTypeArmBand mac:self.peripheralMac];
}

- (void)showUpdateAlert:(KKPreipheralUpdateInfoModel *)info {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"新版本来了" message:info.detail preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [controller  addAction:cancel];
    
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self startDFU:info.url];
    }];
    [controller  addAction:sure];
    [self presentViewController:controller animated:YES completion:nil];
}


# pragma mark - KKBLEArmBandPeripheralDelegate

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveBindResult:(enum KKArmBandBindResult)result {
    switch (result) {
        case KKArmBandBindResultSuccess:
            [self addMessage:@"绑定：成功"];
            break;
        case KKArmBandBindResultFlash:
            [self addMessage:@"绑定失败：flash出错"];
            break;
        case KKArmBandBindResultInSport:
            [self addMessage:@"绑定失败：设备处于运动模式"];
            break;
        case KKArmBandBindResultTimeout:
            [self addMessage:@"绑定失败：超时"];
            break;
        case KKArmBandBindResultUnkonw:
            [self addMessage:@"绑定失败：未知错误"];
            break;
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveSyncTimeResult:(BOOL)result  {
    if (result) {
        [self addMessage:@"时间同步：成功"];
    }  else  {
        [self addMessage:@"时间同步：失败"];
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveSetBrightnessResult:(BOOL)result {
    if (result) {
        [self addMessage:@"设置亮度：成功"];
    } else {
        [self addMessage:@"设置亮度：成功"];
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveBattery:(NSInteger)battery  {
    [self addMessage:[NSString stringWithFormat:@"当前电量：%ld%%",  (long)battery]];
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveSetUserInfoResult:(BOOL)result {
    if (result) {
        [self addMessage:@"用户信息设置：成功"];
    }  else  {
        [self addMessage:@"用户信息设置：失败"];
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveStartSportResult:(enum KKArmBandStartSportResult)result  {
    switch (result) {
        case KKArmBandStartSportResultSuccess:
            [self addMessage:@"运动开启：成功"];
            break;
        case KKArmBandStartSportResultCharging:
            [self addMessage:@"运动开启：失败 -> 正在充电"];
            break;
        case KKArmBandStartSportResultChargeLow:
            [self addMessage:@"运动开启：失败 -> 电量过低"];
            break;
        case KKArmBandStartSportResultUnknown:
            [self addMessage:@"运动开启：失败"];
            break;
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didSportData:(KKArmBandSportDataModel *)data {
    NSString *message = [NSString stringWithFormat:@"运动数据：\n    心率：%ld\n    步数：%ld\n    卡路里：%ld cal\n    距离：%.2f km\n    配速（秒/公⾥）：%ld\n    步频（步/分钟）：%ld", (long)data.heartRate, (long)data.steps, (long)data.calorie, data.distance / 10000.0, (long)data.pace, (long)data.cadence];
    [self addMessage:message];
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveStopSportResult:(BOOL)result {
    if (result) {
        [self addMessage:@"停止运动：成功"];
    }  else  {
        [self addMessage:@"停止运动：失败"];
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveHistoryResult:(enum KKArmBandHistoryResult)result datas:(NSArray<KKArmBandHistoryDataModel *> *)datas {
    switch (result) {
        case KKArmBandHistoryResultSuccess: {
            if (datas.count > 0) {
                [self addMessage:[NSString stringWithFormat:@"历史数据：%lu条数据", (unsigned long)datas.count]];
                for (KKArmBandHistoryDataModel *data in datas) {
                    NSString *message = [NSString stringWithFormat:@"历史数据：\n    距离：%ld\n    持续时间：%lds\n    消耗：%ldcal -> 点击查看详情", (long)data.distance / 10, (long)data.duration, (long)data.calorie];
                    [self addMessage:message detail:[data jsonString]];
                }
            } else {
                [self addMessage:@"历史数据：0条数据"];
            }
            break;
        }
        case KKArmBandHistoryResultInSport:
            [self addMessage:@"读取历史数据：失败 -> 运动模式"];
            break;
    }
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveVersion:(KKPeripheralVersionModel *)version {
    NSString *message = [NSString stringWithFormat:@"版本信息：\n    固件版本：%@\n    bootLoader：%@\n    硬件版本：%@", version.firmware, version.bootLoader,  version.hardware];
    [self addMessage:message];
}

- (void)armBandPeripheral:(KKBLEArmBandPeripheral *)peripheral didReceiveNewVersionInfo:(KKPreipheralUpdateInfoModel *)info {
    if (info) {
        [self addMessage:[NSString stringWithFormat:@"新版本：%@", info.version]];
        [self showUpdateAlert:info];
    } else {
        [self addMessage:@"当前版本已经是最新版本"];
    }
}

# pragma mark - UITableViewDataSource

- (void)addMessage:(NSString *)message {
    
    NSDictionary *dict = @{
        @"title": message
    };
    
    [self.messages addObject:dict];
    [self.tableView reloadData];
    if (!self.isScroll) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (void)addMessage:(NSString *)message detail:(NSString *)detail {
    
    NSDictionary *dict = @{
        @"title": message,
        @"detail": detail
    };
    
    [self.messages addObject:dict];
    [self.tableView reloadData];
    if (!self.isScroll) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}


- (void)replaceMessage:(NSString *)message {
    NSDictionary *dict = @{
        @"title": message
    };
    [self.messages replaceObjectAtIndex:self.messages.count - 1 withObject:dict];
    [self.tableView reloadData];
    if (!self.isScroll) {
        [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.messages.count - 1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ArmBandTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ArmBandTableViewCell" forIndexPath:indexPath];
    NSDictionary *dict = [self.messages objectAtIndex:indexPath.row];
    
    cell.messageLabel.text  = [dict objectForKey:@"title"];
    
    NSString *detail = [dict objectForKey:@"detail"];
    if (detail) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSDictionary *dict = [self.messages objectAtIndex:indexPath.row];
    NSString *detail = [dict objectForKey:@"detail"];
    if (detail) {
        [self showNormalAlertWithTitle:@"数据详情" andMessage:detail];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.isScroll = YES;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate  {
    if (!decelerate) {
        self.isScroll = NO;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.isScroll = NO;
}

# pragma mark - DFU

- (KKBLEPeripheralDFUManager *)dfuManager {
    if (_dfuManager == nil) {
        _dfuManager = [[KKBLEPeripheralDFUManager alloc] init];
        _dfuManager.delegate = self;
    }
    return _dfuManager;
}

- (void)startDFU:(NSString *)urlString {
    [self addMessage:@"开始DFU..."];
    self.isDFU = YES;
    [self.dfuManager updateWithPeripheral:self.peripheral url:urlString];
}

- (void)dfuManagerUpdateSuccess:(KKBLEPeripheralDFUManager *)manager {
    [self addMessage:@"DFU升级：成功"];
    self.isDFU = NO;
    [self connectPeripheral];
}

- (void)dfuManager:(KKBLEPeripheralDFUManager *)manager didUpdateFailure:(enum KKBLEPeripheralDFUManagerError)error {
    [self addMessage:@"DFU升级：失败"];
    self.isDFU = NO;
    [self connectPeripheral];
}

- (void)dfuManager:(KKBLEPeripheralDFUManager *)manager didUpdateProgress:(NSInteger)progress {
    if (progress == 0) {
        [self addMessage:[NSString stringWithFormat:@"DFU升级进度：%ld%%", (long)progress]];
    } else {
        [self replaceMessage:[NSString stringWithFormat:@"DFU升级进度：%ld%%", (long)progress]];
    }
}


- (void)showNormalAlertWithTitle:(NSString *)title andMessage:(NSString  *)message {
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *sure = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [controller addAction:sure];
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)dealloc  {
    [self.centralManager cancelConnectWithPeripheralType:KKPeripheralTypeHealthScale mac:self.peripheralMac];
    NSLog(@"ArmBandViewController dealloc");
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
