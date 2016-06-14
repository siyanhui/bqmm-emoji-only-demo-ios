//
//  MessageModel.h
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MessageModel : NSObject

@property(nonatomic, strong) NSString *name;
@property(nonatomic, strong) NSString *time;
@property(nonatomic, strong) NSString *text;
@property(nonatomic, strong) NSDictionary *ext;

- (instancetype)initWithName:(NSString*)name
                        time:(NSString*)time
                        text:(NSString*)text
                         ext:(NSDictionary*)ext;

@end
