//
//  TEMemoryLabel.m
//  TodayExtension
//
//  Created by Vincent on 2019/5/2.
//  Copyright © 2019 Vincent. All rights reserved.
//

#import "TEMemoryLabel.h"
#import "UIView+MNLayout.h"
#import <sys/sysctl.h>
#import <mach/mach.h>
#include <sys/param.h>
#include <sys/mount.h>
#include <ifaddrs.h>
#include <sys/socket.h>
#include <net/if.h>

@interface TEMemoryLabel ()
@property (nonatomic, strong) UILabel *totalLabel;
@property (nonatomic, strong) UILabel *freeLabel;
@property (nonatomic, strong) UIView *progressBar;
@property (nonatomic, strong) UIView *progressView;
@end

@implementation TEMemoryLabel
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self createView];
    }
    return self;
}

- (void)createView {
    
    UILabel *freeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, self.width_mn/2.f, 12.f)];
    freeLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    freeLabel.font = [UIFont systemFontOfSize:freeLabel.height_mn];
    [self addSubview:freeLabel];
    self.freeLabel = freeLabel;
    
    UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.width_mn/2.f, 0.f, self.width_mn/2.f, 12.f)];
    totalLabel.textAlignment = NSTextAlignmentRight;
    totalLabel.textColor = [[UIColor darkTextColor] colorWithAlphaComponent:.65f];
    totalLabel.font = [UIFont systemFontOfSize:totalLabel.height_mn];
    [self addSubview:totalLabel];
    self.totalLabel = totalLabel;
    
    UIView *progressBar = [[UIView alloc] initWithFrame:CGRectMake(0.f, self.height_mn - 3.5f, self.width_mn, 3.5f)];
    progressBar.layer.cornerRadius = progressBar.height_mn/2.f;
    progressBar.clipsToBounds = YES;
    progressBar.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.1f];
    [self addSubview:progressBar];
    self.progressBar = progressBar;
    
    UIView *progressView = [[UIView alloc] initWithFrame:progressBar.bounds];
    progressView.width_mn = 0.f;
    progressView.backgroundColor = [UIColor colorWithRed:0.f/255.f green:206.f/255.f blue:209.f/255.f alpha:1.f];
    [progressBar addSubview:progressView];
    self.progressView = progressView;
}

- (void)setType:(TEMemoryLabelType)type {
    _type = type;
    if (type == TEMemoryLabelDisk) {
        _progressView.backgroundColor = [UIColor colorWithRed:0.f/255.f green:122.f/255.f blue:254.f/255.f alpha:1.f];
    }
}

- (void)loadData {
    if (self.type == TEMemoryLabelMemory) {
        /// 内存
        float totalMemory = [NSProcessInfo processInfo].physicalMemory;
        float freeMemory = 0.f;
        vm_statistics_data_t vmStats;
        mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
        kern_return_t kernReturn = host_statistics(mach_host_self(),
                                                   HOST_VM_INFO,
                                                   (host_info_t)&vmStats,
                                                   &infoCount);
        if (kernReturn == KERN_SUCCESS) {
            freeMemory = vm_page_size *vmStats.free_count;
        }
        
        CGFloat pro = freeMemory/totalMemory;
        pro = MAX(0.f, MIN(pro, 1.f));
        [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            _progressView.width_mn = _progressBar.width_mn*pro;
        } completion:nil];
        _totalLabel.text = [NSString stringWithFormat:@"总量: %@", [self getFileSizeString:totalMemory]];
        _freeLabel.text = [NSString stringWithFormat:@"可用内存: %@", [self getFileSizeString:freeMemory]];
    } else {
        /// 磁盘
        NSError *error = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
        if (!error && dictionary) {
            NSNumber *fileSize = [dictionary objectForKey:NSFileSystemSize];
            NSNumber *freeSize = [dictionary objectForKey:NSFileSystemFreeSize];
            CGFloat totalSpace = [fileSize floatValue];
            CGFloat freeSpace = [freeSize floatValue];
            
            CGFloat pro = freeSpace/totalSpace;
            pro = MAX(0.f, MIN(pro, 1.f));
            [UIView animateWithDuration:.3f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                _progressView.width_mn = _progressBar.width_mn*pro;
            } completion:nil];
            _totalLabel.text = [NSString stringWithFormat:@"磁盘容量: %@", [self getFileSizeString:totalSpace]];
            _freeLabel.text = [NSString stringWithFormat:@"可用容量: %@", [self getFileSizeString:freeSpace]];
        } else {
            _progressView.width_mn = 0.f;
            _totalLabel.text = @"";
            _freeLabel.text = @"获取磁盘容量失败";
        }
    }
}

- (NSString *)getFileSizeString:(CGFloat)size {
    if (size>1024.f*1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fG",size/1024.f/1024.f/1024.f];
    }
    else if (size < 1024.f*1024.f*1024.f && size >= 1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fM",size/1024.f/1024.f];
    }
    else if (size >= 1024.f && size < 1024.f*1024.f)
    {
        return [NSString stringWithFormat:@"%.1fK",size/1024.f];
    }
    else
    {
        return [NSString stringWithFormat:@"%.1fB",size];
    }
}

@end
