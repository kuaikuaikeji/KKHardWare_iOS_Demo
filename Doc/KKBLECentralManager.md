# KKBLECentralManager

蓝牙中央管理器，管理蓝牙外设状态。

## 使用

### 创建实例

1. 单例模式，管理和反馈全集状态**（适合全局使用）**。

```swift
let centralManager = KKBLECentralManager.manager
```

2. 普通模式，只管理由自己发起的连接状态**（适合单页面使用）**。

```swift
let centralManager = KKBLECentralManager()
```

### 检查蓝牙状态

```swift
// 在使用前先检查蓝牙状态，当状态为poweredOn后在执行后续操作
centralManager.checkState()
```

## 功能

```swift
/// 检查状态
@objc public func checkState()

/// 扫描指定类型的外设
/// - Parameter peripheralType: 外设类型
@objc public func scan(peripheralType: KKPeripheralType)

/// 扫描多个类型的外设
/// - Parameter peripheralTypes: 外设列表
@objc public func scan(peripheralTypes: [KKPeripheralType.RawValue])

/// 停止扫描指定类型的外设
/// - Parameter peripheralType: 外设类型
@objc public func stopScan(peripheralType: KKPeripheralType)

/// 停止扫描
@objc public func stopScan()

/// 连接指定外设
/// - Parameters:
///   - peripheralType: 外设类型
///   - mac: mac地址
@objc public func connect(peripheralType: KKPeripheralType, mac: String)

/// 连接指定外设
/// - Parameter peripheral: 外设
@objc public func connect(peripheral: KKPeripheral)

/// 取消（断开）指定外设连接
/// - Parameters:
///   - peripheralType: 外设类型
///   - mac: mac地址
@objc public func cancelConnect(peripheralType: KKPeripheralType, mac: String)

/// 取消（断开）指定外设连接
/// - Parameter peripheral: 外设
@objc public func cancelConnect(peripheral: KKPeripheral)
```

## 代理

反馈蓝牙状态：

```swift
/// 中心状态发送改变
/// - Parameters:
///   - central: 中心
///   - state: 状态
func centralManager(
  _ central: KKBLECentralManager,
  didUpdateState state: KKBLECentralState
)

/// 发现外设
/// - Parameters:
///   - central: 中心
///   - peripheral: 外设
///   - RSSI: 信号强度
@objc optional func centralManager(
  _ central: KKBLECentralManager,
  didDiscover peripheral: KKPeripheral,
  rssi RSSI: NSNumber
)

/// 外设连接成功
/// - Parameters:
///   - central: 中心
///   - peripheral: 外设
@objc optional func centralManager(
  _ central: KKBLECentralManager,
  didConnect peripheral: KKPeripheral
)

/// 外设连接失败
/// - Parameters:
///   - central: 中心
///   - peripheral: 外设
///   - error: 错误
@objc optional func centralManager(
  _ central: KKBLECentralManager,
  didFailToConnect peripheral: KKPeripheral,
  error: Error?
)

/// 外设断开连接
/// - Parameters:
///   - central: 中心
///   - peripheral: 外设
///   - error: 错误
@objc optional func centralManager(
  _ central: KKBLECentralManager,
  didDisconnectPeripheral peripheral: KKPeripheral,
  error: Error?
)
```

