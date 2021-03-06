//
//  MMTextView.h
//  BQMM SDK
//
//  Created by ceo on 11/9/15.
//  Copyright © 2015 siyanhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMTextView : UITextView

/**
 *  字体
 */
@property (nonatomic,strong) UIFont *mmFont;

/**
 *  字色
 */
@property (nonatomic,strong) UIColor *mmTextColor;

/**
 *  设定视图文本，需要显示表情的地方如果本地有就显示，没有下载后显示
 *
 *  @param mmText 字符串 如:你好[.emojiCode]
 */
- (void)setMMText:(NSString *)mmText;


/**
 *  设定视图文本，需要显示表情的地方如果本地有就显示，没有下载后显示
 *
 *  @param extData           二维数组 如 @[@[@"emojiCode", @1], @[@"text", @0]]
 *  @param completionHandler 完成显示表情后的回调
 */
- (void)setMMText:(NSString*)mmText completionHandler:(void(^)(void))completionHandler;

@end
