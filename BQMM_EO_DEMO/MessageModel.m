//
//  MessageModel.m
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import "MessageModel.h"

@implementation MessageModel

- (instancetype)initWithName:(NSString*)name
                        time:(NSString*)time
                        text:(NSString*)text
                         ext:(NSDictionary*)ext {
    if (self = [super init]) {
        self.name = name;
        self.time = time;
        self.text = text;
        self.ext = ext;
    }
    return self;
}

@end
