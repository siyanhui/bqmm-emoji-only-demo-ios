//
//  MMTextParser.h
//  BQMM_EO_Demo
//
//  Created xiaoqing Teng on 16/5/23.
//  Copyright © 2016 xiaoqing Teng. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BQMM/BQMM.h>

@class MMTextParserModel;

@interface MMTextParser : NSObject
/**
 *  将NSAttributedString字符串转换为表情编码的字符串
 *
 *  @param aStr             NSAttributedString
 */
+ (NSString *)pureTextFromAttributeText:(NSAttributedString *)aStr;

/**
 *  从text中解析Emoji(本地没有的表情远程拉取)
 *
 *  @param model             MMTextParserModel
 *  @param completionHandler 完成的回调，包含MMEmoji, text对象的集合或者(error对象, 用NSNull类型的对象代替)
 */
+ (void)parseMMTextModel:(MMTextParserModel *)model
       completionHandler:(void(^)(NSArray *textImgArray))completionHandler;

/**
 *  计算展示图文混排所需size
 *
 *  @param mmText       你好[.emojiCode],你快乐吗[~emojiCode]
 *  @param font             字体
 *  @param maximumTextWidth 最大显示宽度
 *
 *  @return 展示所需的size
 */
+ (CGSize)sizeForMMText:(NSString *)mmText
                   font:(UIFont *)font
       maximumTextWidth:(CGFloat)maximumTextWidth;

@end

@interface MMTextParserModel : NSObject

/**
 * 原始字符串
 * eg: @"123[.xff]456"
 */
@property (nonatomic, strong) NSString *mmText;
/**
 * 原始字符串根据表情格式分段后的数组, 表情部分替换为NSNull对象
 * eg:@[@"123", null, @"456"]
 */
@property (nonatomic, strong) NSArray *originalData;
/**
 * 原始字符串根据表情格式分段后的数组, 字符串部分替换为@""对象, 表情部分为编码
 * eg:@[@"", @"[.xff]", @""]
 */
@property (nonatomic, strong) NSArray *wrapperCodeData;
/**
 * 原始字符串根据表情格式分段后的数组, 字符串部分替换为@""对象, 表情部分为emojiCode
 * eg:@[@"", @"xff", @""]
 */
@property (nonatomic, strong) NSArray *codeData;

- (instancetype)initWithMMText:(NSString *)mmText;

@end
