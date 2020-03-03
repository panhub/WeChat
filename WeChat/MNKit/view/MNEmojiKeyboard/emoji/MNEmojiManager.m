//
//  MNEmojiManager.m
//  MNKit
//
//  Created by Vincent on 2019/1/31.
//  Copyright © 2019年 小斯. All rights reserved.
//

#import "MNEmojiManager.h"

NSRegularExpression * MNEmojiRegularExpression (void) {
    static NSRegularExpression *emoji_regular_expression;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emoji_regular_expression = [NSRegularExpression regularExpressionWithPattern:@"\\[.+?\\]" options:kNilOptions error:NULL];
    });
    return emoji_regular_expression;
}

NSString * const MNEmojiFavoritesIdentifier = @"favorites";
#define MNEmotionSandboxPath    [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"emotions"]
#define MNEmotionImagePath      [MNEmotionSandboxPath stringByAppendingPathComponent:MNEmojiFavoritesIdentifier]
#define MNEmotionFavoritesPath    [MNEmotionSandboxPath stringByAppendingPathComponent:[MNEmojiFavoritesIdentifier stringByAppendingPathExtension:@"plist"]]

@interface MNEmojiManager ()
@property (nonatomic, strong) NSMutableArray<MNEmojiPacket *>*packets;
@property (nonatomic, strong) NSMutableDictionary <NSString *, MNEmoji *>*caches;
@end

static MNEmojiManager *_manager;
@implementation MNEmojiManager
#pragma mark - Instance
+ (MNEmojiManager *)defaultManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (!_manager) {
            _manager = [[MNEmojiManager alloc] init];
        }
    });
    return _manager;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super allocWithZone:zone];
    });
    return _manager;
}

- (instancetype)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [super init];
        if (_manager) {
            [_manager fatchEmotions];
        }
    });
    return _manager;
}

- (void)fatchEmotions {
    // 创建本地文件夹
    [NSFileManager.defaultManager createDirectoryAtPath:MNEmotionImagePath withIntermediateDirectories:YES attributes:nil error:nil];
    // 加载表情包
    [self filteredEmotionPackets];
    // 加载默认表情
    NSMutableArray <NSDictionary *>*array = @[].mutableCopy;
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:[[MNBundle mainBundle] pathForResource:@"wechat.default" ofType:@"plist" inDirectory:@"plist"]];
    if (dic) [array addObject:dic];
    [array addObject:self.fatchFavoritesPacket];
    // 添加默认表情包
    [[NSFileManager.defaultManager subpathsAtPath:MNEmotionSandboxPath] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.pathExtension isEqualToString:@"plist"] && ![obj containsString:MNEmojiFavoritesIdentifier]) {
            NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:[MNEmotionSandboxPath stringByAppendingPathComponent:obj]];
            if (dic) [array addObject:dic];
        }
    }];
    // 加载表情包
    NSMutableArray <MNEmojiPacket *>*packets = [NSMutableArray arrayWithCapacity:array.count];
    [array enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MNEmojiPacket *packet = [MNEmojiPacket new];
        packet.name = obj[@"name"];
        packet.uuid = obj[@"uuid"];
        packet.desc = obj[@"desc"];
        packet.img = obj[@"img"];
        packet.state = [obj[@"state"] integerValue];
        packet.type = [obj[@"type"] integerValue];
        packet.image = [self imageNamed:packet.img withExtension:nil inPacket:packet.uuid];
        NSArray <NSDictionary *>*emojis = obj[@"emotions"];
        for (NSDictionary *dic in emojis) {
            NSString *img = dic[@"img"];
            NSString *extension = dic[@"extension"];
            UIImage *image = [self imageNamed:img withExtension:extension inPacket:packet.uuid];
            if (!image) continue;
            MNEmoji *emoji = [MNEmoji new];
            emoji.img = img;
            emoji.image = image;
            emoji.desc = dic[@"desc"];
            emoji.extension = extension;
            emoji.packet = packet.uuid;
            emoji.type = [dic[@"type"] integerValue];
            [packet.emojis addObject:emoji];
        }
        if (packet.emojis.count) [packets addObject:packet];
    }];
    self.packets = packets.copy;
}

- (void)filteredEmotionPackets {
    // 寻找表情包名
    NSMutableArray <NSString *>*paths = @[].mutableCopy;
    NSString *bundlePath = [MNBundle.mainBundle pathForResource:@"emotion" ofType:nil];
    NSArray<NSString *> *contents = [NSFileManager.defaultManager contentsOfDirectoryAtPath:bundlePath error:nil];
    [contents enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj containsString:@"default"]) return;
        [paths addObject:[bundlePath stringByAppendingPathComponent:obj]];
    }];
    // 创建本地plist文件
    [paths enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *filePath = [MNEmotionSandboxPath stringByAppendingPathComponent:[obj.lastPathComponent stringByAppendingPathExtension:@"plist"]];
        if ([NSFileManager.defaultManager fileExistsAtPath:filePath]) return;
        NSMutableArray *emotions = @[].mutableCopy;
        [[NSFileManager.defaultManager subpathsAtPath:obj] enumerateObjectsUsingBlock:^(NSString * _Nonnull p, NSUInteger i, BOOL * _Nonnull s) {
            if ([p isEqualToString:@"default"]) return;
            NSMutableDictionary *dic = @{}.mutableCopy;
            [dic setObject:p.pathExtension forKey:@"extension"];
            [dic setObject:p.stringByDeletingPathExtension forKey:@"img"];
            [dic setObject:obj.lastPathComponent forKey:@"packet"];
            [dic setObject:@(MNEmojiTypeImage) forKey:@"type"];
            [dic setObject:p.stringByDeletingPathExtension forKey:@"desc"];
            [emotions addObject:dic];
        }];
        NSMutableDictionary *dic = @{}.mutableCopy;
        [dic setObject:@"本地表情包" forKey:@"desc"];
        [dic setObject:obj.lastPathComponent forKey:@"name"];
        [dic setObject:@"default" forKey:@"img"];
        [dic setObject:@(MNEmojiPacketStateValid) forKey:@"state"];
        [dic setObject:@(MNEmojiPacketTypeImage) forKey:@"type"];
        [dic setObject:obj.lastPathComponent forKey:@"uuid"];
        [dic setObject:emotions.copy forKey:@"emotions"];
        [dic writeToFile:filePath atomically:YES];
    }];
}

// 获取本地收藏夹<没有则创建>
- (NSDictionary *)fatchFavoritesPacket {
    NSDictionary *dic = [[NSDictionary alloc] initWithContentsOfFile:MNEmotionFavoritesPath];
    if (!dic) {
        MNEmoji *emoji = MNEmoji.new;
        emoji.type = MNEmojiTypeFavorites;
        emoji.desc = @"添加表情";
        emoji.img = @"emoticon_favorites_add";
        emoji.packet = MNEmojiFavoritesIdentifier;
        MNEmojiPacket *packet = MNEmojiPacket.new;
        packet.name = @"本地收藏夹";
        packet.desc = @"本地收藏夹";
        packet.img = @"emoticon_favorites";
        packet.state = MNEmojiPacketStateValid;
        packet.type = MNEmojiPacketTypeImage;
        packet.uuid = MNEmojiFavoritesIdentifier;
        [packet.emojis addObject:emoji];
        dic = packet.JsonValue;
        [dic writeToFile:MNEmotionFavoritesPath atomically:YES];
    }
    return dic;
}

#pragma mark - 获取表情图片
- (UIImage *)imageNamed:(NSString *)name withExtension:(NSString *)extension inPacket:(NSString *)packet {
    if (name.length <= 0) return nil;
    if (extension.length <= 0) {
        if ([packet isEqualToString:MNEmojiFavoritesIdentifier]) {
            return [MNBundle imageForResource:name];
        }
        return [self imageForResource:name ofType:@"png" inDirectory:packet];
    }
    if ([extension isEqualToString:@"gif"]) {
        NSString *gifPath = [[MNBundle.mainBundle pathForResource:@"emotion" ofType:nil] stringByAppendingPathComponent:[packet stringByAppendingPathComponent:[name stringByAppendingPathExtension:extension]]];
        NSData *gifData = [NSData dataWithContentsOfFile:gifPath];
        return [UIImage animatedImageWithData:gifData];
    } else {
        if ([packet isEqualToString:MNEmojiFavoritesIdentifier]) {
            return [UIImage imageWithData:[NSData dataWithContentsOfFile:[MNEmotionImagePath stringByAppendingPathComponent:[name stringByAppendingPathExtension:extension]]]];
        } else {
            return [self imageForResource:name ofType:extension inDirectory:packet];
        }
    }
}

- (UIImage *)imageForResource:(NSString *)name ofType:(NSString *)extension inDirectory:(NSString *)directory {
    NSString *filePath = [[MNBundle.mainBundle pathForResource:@"emotion" ofType:nil] stringByAppendingPathComponent:[directory stringByAppendingPathComponent:[name stringByAppendingPathExtension:extension]]];
    if (filePath.length <= 0) return nil;
    return [UIImage imageWithData:[NSData dataWithContentsOfFile:filePath]];
}

#pragma mark - 插入表情图片到收藏夹
- (BOOL)insertEmojiToFavorites:(UIImage *)emojiImage desc:(NSString *)desc {
    if (!emojiImage) return NO;
    if (desc.length <= 0) desc = @"收藏夹表情";
    MNEmojiPacket *packet = self.favoritesPacket;
    if (!packet || packet.emojis.count <= 0) return NO;
    NSString *fileName = [MNFileHandle fileNameWithExtension:@"png"];
    if (![MNFileHandle writeImage:emojiImage toFile:[MNEmotionImagePath stringByAppendingPathComponent:fileName] error:nil]) return NO;
    NSMutableDictionary *packetDic = [[NSDictionary alloc] initWithContentsOfFile:MNEmotionFavoritesPath].mutableCopy;
    NSMutableArray *emojis = [packetDic[@"emotions"] mutableCopy];
    if (emojis.count <= 0) return NO;
    [emojis insertObject:@{@"img":fileName.stringByDeletingPathExtension, @"desc":desc, @"type":@(MNEmojiTypeImage), @"packet":MNEmojiFavoritesIdentifier, @"extension":@"png"} atIndex:1];
    [packetDic setObject:emojis forKey:@"emotions"];
    if (![packetDic.copy writeToFile:MNEmotionFavoritesPath atomically:YES]) return NO;
    MNEmoji *emoji = MNEmoji.new;
    emoji.img = fileName;
    emoji.image = emojiImage;
    emoji.type = MNEmojiTypeImage;
    emoji.desc = desc;
    emoji.packet = packet.uuid;
    [packet.emojis insertObject:emoji atIndex:1];
    return YES;
}

#pragma mark - 根据描述获取表情
- (MNEmoji *)emojiForDesc:(NSString *)desc {
    if (desc.length <= 0 || self.packets.count <= 0) return nil;
    for (MNEmojiPacket *packet in self.packets) {
        if (packet.type != MNEmojiPacketTypeText || packet.state == MNEmojiPacketStateInvalid) continue;
        for (MNEmoji *emoji in packet.emojis) {
            if ([emoji.desc isEqualToString:desc]) return emoji;
        }
    }
    return nil;
}

- (MNEmoji *)emojiForDescUseCache:(NSString *)desc {
    MNEmoji *emoji = [self.caches objectForKey:desc];
    if (!emoji) {
        emoji = [self emojiForDesc:desc];
        if (emoji) [self.caches setObject:emoji forKey:desc];
    }
    return emoji;
}

#pragma mark - 匹配文字中表情部分
+ (NSArray<MNEmojiAttachment *> *)matchingEmojiForString:(NSString *)string {
    if (string.length <= 2) return nil;
    NSArray<NSTextCheckingResult *> *results = [MNEmojiRegularExpression() matchesInString:string options:0 range:NSMakeRange(0, string.length)];
    if (!results || results.count <= 0) return nil;
    NSMutableArray <MNEmojiAttachment *>*attachments = [NSMutableArray arrayWithCapacity:results.count];
    for (NSTextCheckingResult *result in results) {
        if (result.range.location == NSNotFound || result.range.length <= 2) continue;
        NSString *desc = [string substringWithRange:result.range];
        MNEmoji *emoji = [MNEmojiManager.defaultManager emojiForDescUseCache:desc];
        if (!emoji.image) continue;
        MNEmojiAttachment *attachment = [[MNEmojiAttachment alloc] init];
        attachment.range = result.range;
        attachment.desc = desc;
        attachment.image = emoji.image;
        [attachments addObject:attachment];
    }
    return attachments;
}

#pragma mark - 更新表情包
- (BOOL)updatePacket:(MNEmojiPacket *)packet {
    if (packet.type != MNEmojiPacketTypeImage || ![self.packets containsObject:packet]) return NO;
    NSString *filePath = [MNEmotionSandboxPath stringByAppendingPathComponent:[packet.name stringByAppendingPathExtension:@"plist"]];
    NSDictionary *json = packet.JsonValue;
    return [json writeToFile:filePath atomically:YES];
}

#pragma mark - Getter
- (NSMutableDictionary <NSString *, MNEmoji *>*)caches {
    if (!_caches) {
        _caches = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return _caches;
}

- (MNEmojiPacket *)favoritesPacket {
    __block MNEmojiPacket *packet;
    [self.packets enumerateObjectsUsingBlock:^(MNEmojiPacket * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj.uuid isEqualToString:MNEmojiFavoritesIdentifier]) {
            packet = obj;
            *stop = YES;
        }
    }];
    return packet;
}

@end
