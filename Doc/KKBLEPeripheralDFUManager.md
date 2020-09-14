# KKBLEPeripheralDFUManager

DFU管理器，管理外设固件升级：

```swift
/// 升级
/// - Parameters:
///   - peripheral: 外设
///   - url: 固件地址
@objc public func update(peripheral: KKPeripheral, url: String)
```

## 代理

### 设置代理

```swift
// 创建实例
let dfuManager = KKBLEPeripheralDFUManager()
// 设置代理
dfuManager.delegate = self
```

### 代理回调

```swift
/// 升级成功回调
/// - Parameter manager: DFU管理器
func dfuManagerUpdateSuccess(_ manager: KKBLEPeripheralDFUManager)

/// 升级失败回调
/// - Parameters:
///   - manager: DFU管理器
///   - error: 错误
func dfuManager(_ manager: KKBLEPeripheralDFUManager, didUpdateFailure error: KKBLEPeripheralDFUManagerError)


/// 升级进度回调
/// - Parameters:
///   - manager: DFU管理器
///   - progress: 进度
@objc optional func dfuManager(_ manager: KKBLEPeripheralDFUManager, didUpdateProgress progress: Int)
```

