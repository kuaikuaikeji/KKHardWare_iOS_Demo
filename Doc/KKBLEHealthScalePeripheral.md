# KKBLEHealthScalePeripheral

体脂秤外设，封装了体脂称功能：

```swift
/// 读取身体数据
/// - Parameters:
///   - userUUID: 用户UUID（唯一标示）
///   - sex: 性别
///   - age: 年龄
///   - height: 身高（cm）
@objc public func readBodyData(userUUID: String, sex: KKSexType, age: Int, height: Double)

/// 读取身体报告
@objc public func readBodyReport()
```

## 代理

### 设置代理

```swift
/// 添加代理
/// - Parameter delegate: 代理
@objc public func appendDelegate(_ delegate: KKBLEHealthScalePeripheralDelegate)

/// 移除代理
/// - Parameter delegate: 代理
@objc public func removeDelegate(_ delegate: KKBLEHealthScalePeripheralDelegate)
```

### 代理回调

```swift
/// 接收到 身体数据
/// - Parameters:
///   - peripheral: 外设
///   - data: 身体数据
///   - errorType: 错误
func healthScalePeripheral
(_ peripheral: KKBLEHealthScalePeripheral,
 didReceiveBodyData data: KKHealthScaleBodyDataModel,
 errorType: KKHealthScaleBodyDataErrorType
)


/// 接受到报告数据
/// - Parameters:
///   - peripheral: 外设
///   - data: 报告数据
///   - errorType: 错误
func healthScalePeripheral(
  _ peripheral: KKBLEHealthScalePeripheral,
  didReceiveReportData data: String?,
  errorType: KKHealthScaleReportDataErrorType
)
```

