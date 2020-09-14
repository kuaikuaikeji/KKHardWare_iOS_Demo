# KKBLEPeripheralSDK

快快家用蓝牙外设SDK。

## 安装

### Cocoapods

1. 在 [Podfile]()  中添加 `pod 'KKBLEPeripheralSDK'`

2. 运行 `pod install` 命令下载SDK。

### 手动安装

1. 下载 [SDK](https://kuaikuai.oss-cn-beijing.aliyuncs.com/upload/aee5639b-00d2-4e8f-beac-5081c0776106.zip)，导入项目。

> 注意：
>
> SDK采用Swift开发，如果是纯OC项目，需要在项目中建立一个空的Swift文件。

## 使用

SDK使用了蓝牙位置权限，需要在[info.plist](Example/Info.plist)里添加蓝牙权限。

```swift
Privacy - Bluetooth Always Usage Description 
Privacy - Bluetooth Peripheral Usage Description
```

### 导入

OC：

```objective-c
#import <KKBLEPeripheralSDK/KKBLEPeripheralSDK-Swift.h>
```

Swift：

```swift
import KKBLEPeripheralSDK
```

### 注册

在使用SDK前先注册App。

OC：

```objective-c
[KKBLEPeripheralAPI registerWithAppID:@"" callBack:^(BOOL result) {
}];
```

Swift：

```swift
KKBLEPeripheralAPI.register(appID: "") { (result) in
    
}
```

### 文档

[KKBLECentralManager](./Doc/KKBLECentralManage.md)：蓝牙中央管理器，管理蓝牙外设状态。

[KKBLEArmBandPeripheral](Doc/KKBLEArmBandPeripheral.md)：蓝牙臂带外设，封装了臂带功能。

[KKBLEHealthScalePeripheral](Doc/KKBLEHealthScalePeripheral.md)：蓝牙体脂秤外设，封装了体脂称功能。

[KKBLEPeripheralDFUManager](Doc/KKBLEPeripheralDFUManager.md)：DFU管理器，管理外设固件升级。

