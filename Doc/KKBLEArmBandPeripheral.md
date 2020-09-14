# KKBLEArmBandPeripheral

蓝牙臂带外设，封装了臂带功能：

```swift
/// 设置LED亮度
/// - Parameter level: 亮度等级（1 ～ 10）
@objc public func setBrightness(
  level: Int
)

/// 设置时间（时间同步）
@objc public func setTime(date: Date)

/// 读取电量
@objc public func readBattery()

/// 读取版本号
@objc public func readVersion()

/// 检查新版本
@objc public func checkNewVersion()

/// 设置用户信息
/// - Parameters:
///   - userUUID: 用户UUID（唯一标示）
///   - sex: 性别
///   - age: 年龄
///   - height: 身高（cm）
///   - weight: 体重（kg）
///   - pulse: 静态心率
@objc public func setUser(
  userUUID: String,
  sex: KKSexType,
  age: Int,
  height: Double,
  weight: Double,
  pulse: Int
)

/// 开始绑定
/// - Parameter timeout: 超时时间
@objc public func bind(timeout: Double)

/// 开始运动
/// - Parameters:
///   - sportType: 运动类型
///   - startMetronome: 是否开启节拍器
///   - cadence: 步频(步/分钟)
///   - dataReturnCycle: 数据自动返回周期，可设置为（1 ～ 14）设置其他值则不会自动返回运动数据。
@objc public func startSport(
  sportType: KKPeripheralOnlineSportType,
  startMetronome: Bool,
  cadence: Int,
  dataReturnCycle: Int
)


/// 开始运动（多设备运动使用）
/// - Parameters:
///   - sportType: 运动类型
///   - startMetronome: 是否开启节拍器
///   - cadence: 步频(步/分钟)
///   - time: 多设备数据同步使用，保持时间一致
///   - dataReturnCycle: 数据自动返回周期，可设置为（1 ～ 14）设置其他值则不会自动返回运动数据。
@objc public func startSport(
  sportType: KKPeripheralOnlineSportType,
  startMetronome: Bool,
  cadence: Int,
  time: Date,
  dataReturnCycle: Int
)

/// 读取运动数据
/// - Parameter cal: 当前的卡路里（同步数据使用，设备断开或其他异常情况）
@objc public func readSportData(
  cal: Int
)

/// 停止运动
@objc public func stopSport() 

/// 停止运动（多设备运动使用）
/// - Parameter time: 多设备数据同步使用，保持时间一致
@objc public func stopSport(time: Date)

/// 读取历史数据
@objc public func readHistoryData()

/// 寻找设备
@objc public func seek()
```

## 代理

### 设置代理

```swift
/// 添加代理
/// - Parameter delegate: 代理
@objc public func appendDelegate(_ delegate: KKBLEArmBandPeripheralDelegate)

/// 移除代理
/// - Parameter delegate: 代理
@objc public func removeDelegate(_ delegate: KKBLEArmBandPeripheralDelegate)
```

### 代理回调

```swift
/// 绑定结果返回
/// - Parameters:
///   - peripheral: 臂带外设
///   - result: 绑定结果
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveBindResult result: KKArmBandBindResult
)

/// 电量返回
/// - Parameters:
///   - peripheral: 臂带外设
///   - battery: 电量（0 ~ 100）
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveBattery battery: Int
)

/// 配置用户信息结果返回
/// - Parameters:
///   - peripheral: 臂带外设
///   - result: 是否配置成功
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveSetUserInfoResult result: Bool
)

/// 配置亮度结果返回
/// - Parameters:
///   - peripheral: 臂带外设
///   - result: 是否配置成功
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveSetBrightnessResult result: Bool
)

/// 同步时间结果
/// - Parameters:
///   - peripheral: 臂带外设
///   - result: 是否同步成功
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveSyncTimeResult result: Bool
)

/// 外设版本返回
/// - Parameters:
///   - peripheral: 外设
///   - version: 版本信息
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveVersion version: KKPeripheralVersionModel
)

/// 检查新版结果返回
/// - Parameters:
///   - peripheral: 外设
///   - info: 新版本信息，`nil` 表示没有新版本
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveNewVersionInfo info: KKPreipheralUpdateInfoModel?
)

/// 历史数据返回
/// - Parameters:
///   - peripheral: 外设
///   - result: 结果
///   - datas: 数据
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveHistoryResult result:KKArmBandHistoryResult,
  datas: [KKArmBandHistoryDataModel]
)

/// 开始运动结果返回
/// - Parameters:
///   - peripheral: 外设
///   - result: 开始结果
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveStartSportResult result: KKArmBandStartSportResult
)

/// 运动实时数据返回
/// - Parameters:
///   - peripheral: 外设
///   - data: 运动数据
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didSportData data: KKArmBandSportDataModel
)

/// 停止运动结果返回
/// - Parameters:
///   - peripheral: 外设
///   - result: 是否停止成功
@objc optional func armBandPeripheral(
  _ peripheral: KKBLEArmBandPeripheral,
  didReceiveStopSportResult result: Bool
)
```

