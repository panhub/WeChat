//
//  MNCallback.h
//  MNKit
//
//  Created by Vincent on 2018/9/22.
//  Copyright © 2018年 小斯. All rights reserved.
//  定义公用回调 

#ifndef MNHandler_h
#define MNHandler_h

typedef void(^MNVoidHandler)(void);
typedef void(^MNSingleHandler)(id);
typedef void(^MNBOOLHandler)(BOOL);

typedef id (^MNReturnHandler)(void);

#endif /* MNHandler_h */
