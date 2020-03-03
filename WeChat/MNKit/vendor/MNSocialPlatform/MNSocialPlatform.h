//
//  MNSocialPlatform.h
//  MNKit
//
//  Created by Vincent on 2019/2/16.
//  Copyright © 2019年 小斯. All rights reserved.
//  友盟社会化分享

#import <Foundation/Foundation.h>
#if __has_include(<UMShare/UMShare.h>)
#import <UMShare/UMShare.h>

typedef void(^UMSocialShareHandler)(id result, NSError *error);

@interface MNSocialPlatform : NSObject

/**
 分享网页到指定平台
 @param url 网址
 @param title 标题
 @param desc 描述
 @param thumbnailImage 缩略图<UIImage, NSData, NSString>
 @param platform 平台
 @param handler 回调
 */
+ (void)shareWebPageWithUrl:(NSString *)url
                      title:(NSString *)title
                       desc:(NSString *)desc
                  thumbnailImage:(id)thumbnailImage
                   platform:(UMSocialPlatformType)platform
                    completion:(UMSocialShareHandler)handler;

/**
 分享视频到指定平台
 @param url 视频地址
 @param title 标题
 @param desc 描述
 @param thumbnailImage 缩略图<UIImage, NSData, NSString>
 @param platform 平台
 @param handler 回调
 */
+ (void)shareVideoWithUrl:(NSString *)url
                      title:(NSString *)title
                       desc:(NSString *)desc
                  thumbnailImage:(id)thumbnailImage
                   platform:(UMSocialPlatformType)platform
                 completion:(UMSocialShareHandler)handler;

/**
 分享音乐到指定平台
 @param url 音乐地址
 @param title 标题
 @param desc 描述
 @param thumbnailImage 缩略图<UIImage, NSData, NSString>
 @param platform 平台
 @param handler 回调
 */
+ (void)shareMusicWithUrl:(NSString *)url
                    title:(NSString *)title
                     desc:(NSString *)desc
                thumbnailImage:(id)thumbnailImage
                 platform:(UMSocialPlatformType)platform
               completion:(UMSocialShareHandler)handler;

/**
 分享图片到指定平台
 @param images 图片数组 <UIImage, NSData, NSString (微博<9>, QZone<20>, 其它<1>)>
 @param thumbnailImage 缩略图 <UIImage, NSData, NSString>
 @param platform 平台
 @param handler 结果回调
 */
+ (void)shareImages:(NSArray <id>*)images
          thumbnailImage:(id)thumbnailImage
           platform:(UMSocialPlatformType)platform
            completion:(UMSocialShareHandler)handler;

/**
 授权并获取用户信息
 @param platform 平台
 @param handler 回调
 */
+ (void)handAuthInfoWithPlatform:(UMSocialPlatformType)platform completion:(UMSocialShareHandler)handler;


/**
 在 Other Linker Flags 加入 -ObjC
 
 系统
 libsqlite3.tbd
 CoreGraphics.framework
 
 微信
 SystemConfiguration.framework
 CoreTelephony.framework
 libsqlite3.tbd
 libc++.tbd
 libz.tbd
 
 QQ
 SystemConfiguration.framework
 libc++.tbd
 
 微博
 SystemConfiguration.framework
 CoreTelephony.framework
 ImageIO.framework
 libsqlite3.tbd
 libz.tbd
 Photos.framework
 
 短信
 MessageUI.framework
 
 权限
 <key>NSPhotoLibraryUsageDescription</key>
 <string>App需要您的同意,才能访问相册</string>
 <key>NSAppTransportSecurity</key>
 <dict>
 <key>NSAllowsArbitraryLoads</key>
 <true/>
 </dict>
 
 白名单
 <key>LSApplicationQueriesSchemes</key>
 <array>
 <!-- 微信 URL Scheme 白名单-->
 <string>wechat</string>
 <string>weixin</string>
 
 <!-- 新浪微博 URL Scheme 白名单-->
 <string>sinaweibohd</string>
 <string>sinaweibo</string>
 <string>sinaweibosso</string>
 <string>weibosdk</string>
 <string>weibosdk2.5</string>
 
 <!-- QQ、Qzone URL Scheme 白名单-->
 <string>mqqapi</string>
 <string>mqq</string>
 <string>mqqOpensdkSSoLogin</string>
 <string>mqqconnect</string>
 <string>mqqopensdkdataline</string>
 <string>mqqopensdkgrouptribeshare</string>
 <string>mqqopensdkfriend</string>
 <string>mqqopensdkapi</string>
 <string>mqqopensdkapiV2</string>
 <string>mqqopensdkapiV3</string>
 <string>mqqopensdkapiV4</string>
 <string>mqzoneopensdk</string>
 <string>wtloginmqq</string>
 <string>wtloginmqq2</string>
 <string>mqqwpa</string>
 <string>mqzone</string>
 <string>mqzonev2</string>
 <string>mqzoneshare</string>
 <string>wtloginqzone</string>
 <string>mqzonewx</string>
 <string>mqzoneopensdkapiV2</string>
 <string>mqzoneopensdkapi19</string>
 <string>mqzoneopensdkapi</string>
 <string>mqqbrowser</string>
 <string>mttbrowser</string>
 <string>tim</string>
 <string>timapi</string>
 <string>timopensdkfriend</string>
 <string>timwpa</string>
 <string>timgamebindinggroup</string>
 <string>timapiwallet</string>
 <string>timOpensdkSSoLogin</string>
 <string>wtlogintim</string>
 <string>timopensdkgrouptribeshare</string>
 <string>timopensdkapiV4</string>
 <string>timgamebindinggroup</string>
 <string>timopensdkdataline</string>
 <string>wtlogintimV1</string>
 <string>timapiV1</string>
 
 <!-- 支付宝 URL Scheme 白名单-->
 <string>alipay</string>
 <string>alipayshare</string>
 
 <!-- 钉钉 URL Scheme 白名单-->
 <string>dingtalk</string>
 <string>dingtalk-open</string>
 
 <!--Linkedin URL Scheme 白名单-->
 <string>linkedin</string>
 <string>linkedin-sdk2</string>
 <string>linkedin-sdk</string>
 
 <!-- 点点虫 URL Scheme 白名单-->
 <string>laiwangsso</string>
 
 <!-- 易信 URL Scheme 白名单-->
 <string>yixin</string>
 <string>yixinopenapi</string>
 
 <!-- instagram URL Scheme 白名单-->
 <string>instagram</string>
 
 <!-- whatsapp URL Scheme 白名单-->
 <string>whatsapp</string>
 
 <!-- line URL Scheme 白名单-->
 <string>line</string>
 
 <!-- Facebook URL Scheme 白名单-->
 <string>fbapi</string>
 <string>fb-messenger-api</string>
 <string>fb-messenger-share-api</string>
 <string>fbauth2</string>
 <string>fbshareextension</string>
 
 <!-- Kakao URL Scheme 白名单-->
 <!-- 注：以下第一个参数需替换为自己的kakao appkey-->
 <!-- 格式为 kakao + "kakao appkey"-->
 <string>kakaofa63a0b2356e923f3edd6512d531f546</string>
 <string>kakaokompassauth</string>
 <string>storykompassauth</string>
 <string>kakaolink</string>
 <string>kakaotalk-4.5.0</string>
 <string>kakaostory-2.9.0</string>
 
 <!-- pinterest URL Scheme 白名单-->
 <string>pinterestsdk.v1</string>
 
 <!-- Tumblr URL Scheme 白名单-->
 <string>tumblr</string>
 
 <!-- 印象笔记 -->
 <string>evernote</string>
 <string>en</string>
 <string>enx</string>
 <string>evernotecid</string>
 <string>evernotemsg</string>
 
 <!-- 有道云笔记-->
 <string>youdaonote</string>
 <string>ynotedictfav</string>
 <string>com.youdao.note.todayViewNote</string>
 <string>ynotesharesdk</string>
 
 <!-- Google+-->
 <string>gplus</string>
 
 <!-- Pocket-->
 <string>pocket</string>
 <string>readitlater</string>
 <string>pocket-oauth-v1</string>
 <string>fb131450656879143</string>
 <string>en-readitlater-5776</string>
 <string>com.ideashower.ReadItLaterPro3</string>
 <string>com.ideashower.ReadItLaterPro</string>
 <string>com.ideashower.ReadItLaterProAlpha</string>
 <string>com.ideashower.ReadItLaterProEnterprise</string>
 
 <!-- VKontakte-->
 <string>vk</string>
 <string>vk-share</string>
 <string>vkauthorize</string>
 
 <!-- Twitter-->
 <string>twitter</string>
 <string>twitterauth</string>
 </array>
 
 
 配置第三方平台URL Scheme未列出则不需设置
 
 平台    格式    举例    备注
 微信    微信appKey    wxdc1e388c3822c80b
 QQ/Qzone    需要添加两项URL Scheme：
 1、"tencent"+腾讯QQ互联应用appID
 2、“QQ”+腾讯QQ互联应用appID转换成十六进制（不足8位前面补0）    如appID：100424468 1、tencent100424468
 2、QQ05fc5b14    QQ05fc5b14为100424468转十六进制而来，因不足8位向前补0，然后加"QQ"前缀
 新浪微博    “wb”+新浪appKey    wb3921700954
 支付宝    “ap”+appID    ap2015111700822536    URL Type中的identifier填"alipayShare"
 钉钉    钉钉appkey    dingoalmlnohc0wggfedpk    identifier的参数都使用dingtalk
 易信    易信appkey    yx35664bdff4db42c2b7be1e29390c1a06
 点点虫    点点虫appID    8112117817424282305    URL Type中的identifier填"Laiwang"
 领英    “li”+appID    li4768945
 Facebook    “fb”+FacebookID    fb506027402887373
 Twitter    “twitterkit-”+TwitterAppkey    twitterkit-fB5tvRpna1CKK97xZUslbxiet
 VKontakte “vk”+ VKontakteID    vk5786123
 */

@end
#endif
