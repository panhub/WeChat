##### MNKit
1. FFmpeg<4.2> 最低支持9.3
2. Add libbz2, libc++, libiconv4, libz, CoreMotion, GameController, VideoToolbox, Accelerate 系统框架/静态库 <FFmpeg 所需>
3. Build Settings - Enable Bitcode - NO <音频转码库所需>
4. Build Settings - Implicit retain of 'self' within blocks - NO <块儿内使用self消除警告>
5. Build Settings - Asset Catalog Launch Image Set Name - LaunchImage<使用LaunchImage启动>
6. AppDelegate 增加window属性并删除分屏代理
7. 依据"MNFramework.h"导入系统框架
8. plist 设置 

    /**权限申请*/
    <key>NSCalendarsUsageDescription</key>
    <string>需要使用日历获取当前时间</string>
    <key>NSCameraUsageDescription</key>
    <string>需要使用相机来扫描图像</string>
    <key>NSContactsUsageDescription</key>
    <string>需要使用通讯录获取联系人信息</string>
    <key>NSLocationWhenInUseUsageDescription</key>
    <string>需要使用定位获取位置信息</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>需要使用麦克风来录音</string>
    <key>NSPhotoLibraryAddUsageDescription</key>
    <string>需要您的同意保存图片</string>
    <key>NSPhotoLibraryUsageDescription</key>
    <string>需要打开相册选取照片或视频</string>
    <key>NSUserTrackingUsageDescription</key>
    <string>需要获取IDFA统计信息</string>
    <key>NSFaceIDUsageDescription</key>
    <string>需要使用FaceID验证登录</string>
    
    /**关闭暗黑模式*/
    <key>User Interface Style</key>
    <string>Light</string>
    
    /**状态栏动态效果支持*/
    <key>UIViewControllerBasedStatusBarAppearance</key>
    <false/>
    
9. 添加环境变量
    OS_ACTIVITY_MODE        disable
    
##### YYKit
1. Add -fno-objc-arc To File NSThread+YYAdd
2. Add -fno-objc-arc To File NSObject+YYAddForARC
