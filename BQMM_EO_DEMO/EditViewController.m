//
//  EditViewController.m
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import "EditViewController.h"
#import "CommentTextView.h"
#import "define.h"
#import "MessageModel.h"

#import <BQMM/BQMM.h>

@interface EditViewController () <MMEmotionCentreDelegate, UITextViewDelegate>

@property(nonatomic, strong) IBOutlet UITextView *inputTextView;
@property(nonatomic, strong) IBOutlet UIButton *faceButton;
@property(nonatomic, strong) IBOutlet NSLayoutConstraint *toolBarBottomLayout;

@end

@implementation EditViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"发评论";
    
    UIButton *cancel = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 24)];
    [cancel setTitle:@"取消" forState:UIControlStateNormal];
    cancel.titleLabel.font = [UIFont systemFontOfSize:15];
    [cancel setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [cancel addTarget:self action:@selector(cancelAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:cancel];
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 54, 24)];
    sendButton.backgroundColor = RGB(0x34, 0xC9, 0xB5);
    [sendButton setTitle:@"发送" forState:UIControlStateNormal];
    sendButton.titleLabel.font = [UIFont systemFontOfSize:15];
    [sendButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sendButton.layer.cornerRadius = 4;
    [sendButton addTarget:self action:@selector(sendAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:sendButton];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [MMEmotionCentre defaultCentre].delegate = self;
}

- (void)cancelAction:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendAction:(id)sender {
    [self sendMmText:self.inputTextView.text];
}

- (IBAction)faceAction:(id)sender {
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
    
    if (![self.inputTextView isFirstResponder]) {
        [self.inputTextView becomeFirstResponder];
    }
    
    if (button.isSelected) {
        [[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:self.inputTextView];
    } else {
        [[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
    }
}

-(void)keyboardWillShow:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGRect endFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __weak typeof(self) weakself = self;
    void(^animations)() = ^{
        weakself.toolBarBottomLayout.constant = endFrame.size.height;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

-(void)keyboardWillHide:(NSNotification*)notification {
    NSDictionary *userInfo = notification.userInfo;
    CGFloat duration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve = [userInfo[UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    __weak typeof(self) weakself = self;
    void(^animations)() = ^{
        weakself.toolBarBottomLayout.constant = 0;
    };
    
    void(^completion)(BOOL) = ^(BOOL finished){
    };
    
    [UIView animateWithDuration:duration delay:0.0f options:(curve << 16 | UIViewAnimationOptionBeginFromCurrentState) animations:animations completion:completion];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - *Func

- (void)sendMmText:(NSString*)mmText {
    NSString *str = [NSString stringWithString:mmText];
    str = [mmText stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    str = [mmText stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [mmText stringByReplacingOccurrencesOfString:@"\a" withString:@""];
    str = [mmText stringByReplacingOccurrencesOfString:@" " withString:@""];
    if (str.length <= 0) {
        return;
    }
    
    NSString *sendStr = [mmText stringByReplacingOccurrencesOfString:@"\a" withString:@""];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    MessageModel *model = [[MessageModel alloc] initWithName:@"表情mm" time:[dateFormatter stringFromDate:[NSDate date]] text:sendStr ext:nil];
    [self.delegate onSend:model];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - *UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView {

}

#pragma mark - *MMEmotionCentreDelegate

- (void)didSelectEmoji:(MMEmoji *)emoji {
    
}

- (void)didSelectTipEmoji:(MMEmoji *)emoji {
    
}

- (void)didSendWithInput:(UIResponder<UITextInput> *)input {
    [self sendMmText:self.inputTextView.text];
}

- (void)tapOverlay {
    self.faceButton.selected = NO;
}

@end

















