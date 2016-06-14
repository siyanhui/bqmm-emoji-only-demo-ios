//
//  ShowTableViewCell.h
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;

@interface ShowTableViewCell : UITableViewCell

@property(nonatomic, strong) MessageModel *model;

+ (CGFloat)heightWithModel:(MessageModel*)model;

@end
