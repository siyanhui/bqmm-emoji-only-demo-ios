//
//  ShowTableViewCell.m
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import "ShowTableViewCell.h"
#import "define.h"
#import "MessageModel.h"
#import "MMTextView.h"
#import "MMTextParser.h"

#define LEFT_RIGHT_PADDING 25
#define TOP_BOTTOM_PADDING 16

@interface ShowTableViewCell ()

@property(nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, strong) UILabel *timeLabel;
@property(nonatomic, strong) MMTextView *textView;
@property(nonatomic, strong) UIView *split;

@end

@implementation ShowTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        _nameLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        [self.contentView addSubview:_nameLabel];
        
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.textColor = RGB(0x61, 0x61, 0x61);
        _timeLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:_timeLabel];
        
        _textView = [[MMTextView alloc] init];
        _textView.mmFont = [UIFont systemFontOfSize:15];
        _textView.editable = NO;
        [self.contentView addSubview:_textView];
        
        _split = [[UIView alloc] init];
        _split.backgroundColor = RGB(0xAC, 0xAC, 0xAC);
        [self.contentView addSubview:_split];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat maxWidth = size.width - LEFT_RIGHT_PADDING * 2;
    
    CGSize nameLabelSize = [_nameLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_nameLabel.font} context:nil].size;
    _nameLabel.frame = CGRectMake(LEFT_RIGHT_PADDING, TOP_BOTTOM_PADDING, nameLabelSize.width, nameLabelSize.height);
    
    CGSize timeLabelSize = [_timeLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:_timeLabel.font} context:nil].size;
    _timeLabel.frame = CGRectMake(LEFT_RIGHT_PADDING, TOP_BOTTOM_PADDING + nameLabelSize.height, timeLabelSize.width, timeLabelSize.height);
    
    CGSize textViewSize = [MMTextParser sizeForMMText:self.model.text font:[UIFont systemFontOfSize:15] maximumTextWidth:maxWidth];
    _textView.frame = CGRectMake(LEFT_RIGHT_PADDING, TOP_BOTTOM_PADDING + nameLabelSize.height + timeLabelSize.height, textViewSize.width, textViewSize.height);
    
    _split.frame = CGRectMake(0, self.contentView.bounds.size.height-1, self.contentView.bounds.size.width, 1);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setModel:(MessageModel *)model {
    _model = model;
    
    _nameLabel.text = model.name;
    _timeLabel.text = model.time;
    [_textView setMMText:model.text];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    _textView.text = nil;
    _nameLabel.text = nil;
    _timeLabel.text = nil;
}

+ (CGFloat)heightWithModel:(MessageModel*)model {
    CGSize size = [[UIScreen mainScreen] bounds].size;
    CGFloat maxWidth = size.width - LEFT_RIGHT_PADDING * 2;
    
    CGSize nameLabelSize = [model.name boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:15]} context:nil].size;
    
    CGSize timeLabelSize = [model.time boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
    
    
    CGSize textViewSize = [MMTextParser sizeForMMText:model.text font:[UIFont systemFontOfSize:15] maximumTextWidth:maxWidth];
    
    return nameLabelSize.height + timeLabelSize.height + textViewSize.height + TOP_BOTTOM_PADDING * 2;
}

@end

























