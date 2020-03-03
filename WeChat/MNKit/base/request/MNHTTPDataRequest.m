//
//  MNHTTPDataRequest.m
//  MNKit
//
//  Created by Vincent on 2018/11/21.
//  Copyright © 2018年 小斯. All rights reserved.
//

#import "MNHTTPDataRequest.h"

@interface MNHTTPDataRequest ()
@property (nonatomic, strong, readwrite) NSMutableArray *dataArray;
@end

@implementation MNHTTPDataRequest
- (void)initialized {
    [super initialized];
    _page = 1;
    _more = NO;
    _pagingEnabled = NO;
    _dataArray = [NSMutableArray arrayWithCapacity:0];
}

- (void)didLoadSucceedWithResponseObject:(id)responseObject {
    if (_page == 1) [self cleanMemoryCache];
}

- (void)prepareReloadData {
    _page = 1;
}

- (BOOL)isDataEmpty {
    return _dataArray.count <= 0;
}

- (void)cleanMemoryCache {
    [_dataArray removeAllObjects];
}

@end
