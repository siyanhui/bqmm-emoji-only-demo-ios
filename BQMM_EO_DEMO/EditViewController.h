//
//  EditViewController.h
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MessageModel;

@protocol EditViewDelegate <NSObject>

- (void)onSend:(MessageModel*)model;

@end

@interface EditViewController : UIViewController

@property(nonatomic, strong) id<EditViewDelegate> delegate;

@end
