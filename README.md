#Emoji Only版接入说明


##0. 注册AppId&AppSecret

在 `AppDelegate` 的 `-application:didFinishLaunchingWithOptions:` 中添加：

```objectivec
// 初始化SDK
[[MMEmotionCentre defaultCentre] setAppId:@“your app id” secret:@“your secret”]
```

##1. 添加表情键盘

设置SDK代理

```objectivec
[MMEmotionCentre defaultCentre].delegate = self;
```

添加表情键盘

```objectivec
if (![self.inputTextView isFirstResponder]) {
        [self.inputTextView becomeFirstResponder];
    }
[[MMEmotionCentre defaultCentre] attachEmotionKeyboardToInput:self.inputTextView];
```

由表情键盘切换为普通键盘

```objectivec
[[MMEmotionCentre defaultCentre] switchToDefaultKeyboard];
```

##2. 在App重新打开时清空session

在 `AppDelegate` 的 `- (void)applicationWillEnterForeground:` 中添加：

```objectivec
[[MMEmotionCentre defaultCentre] clearSession];
```

##3. 表情消息编辑控件

SDK提供UITextView+BQMM作为表情编辑控件的扩展实现，访问UITextView的text属性可获取含有表情编码的字符窜。

##4. 实现表情消息发送相关代理方法

```objectivec
#pragma mark - *MMEmotionCentreDelegate
//点击表情小表情键盘上发送按钮的代理
- (void)didSendWithInput:(UIResponder<UITextInput> *)input {
    [self sendMmText:self.inputTextView.text];
}

//点击输入框切换表情按钮状态
- (void)tapOverlay {
    self.faceButton.selected = NO;
}
```

实际发送消息的方法（Demo）：

```objectivec
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

```

##5. 表情消息解析
我们将表情解析部分的代码从表情mm SDK中分离出来，方便开发者根据自己的业务实现表情图片的解析逻辑，同时我们在Demo中提供了`MMTextView`，作为表情消息解析和显示的示例。

首先，在`MMTextParser`中提供从消息编辑控件的attributedString解析出含表情编码的字符串的方法：

```objectivec
+ (NSString *)pureTextFromAttributeText:(NSAttributedString *)aStr;
```

然后通过含表情编码的字符串构造`MMTextParserModel`

```objectivec
- (instancetype)initWithMMText:(NSString *)mmText;
```

最后`MMTextParser`从`MMTextParserModel`中解析出包含MMEmoji和 text对象的集合

```objectivec
+ (void)parseMMTextModel:(MMTextParserModel *)model
       completionHandler:(void(^)(NSArray *textImgArray))completionHandler;
```

##6. 表情消息显示

SDK Demo提供`MMTextView.h`和`MMTextView.m`作为显示表情消息的示例。使用方法：

```objectivec
_textView = [[MMTextView alloc] init];
_textView.mmFont = [UIFont systemFontOfSize:15];
_textView.editable = NO;
[self.contentView addSubview:_textView];
```

设置MMTextView的内容（mmText是包含表情编码的字符窜）

```objectivec
- (void)setMMText:(NSString *)mmText
```

另外，开发者可参照MMTextView中的

```objectivec
- (void)updateAttributeTextWithMmTextModel:(MMTextParserModel *)model completionHandler:(void(^)(void))completionHandler;
- (void)transAttachmentToImageViews;
```
 方法定义自己的表情消息显示方式。


##7. UI定制

表情mm SDK通过`MMTheme`提供一定程度的UI定制。具体参考类说明[MMTheme](../class_reference/README.md)。

创建一个`MMTheme`对象，设置相关属性， 然后[[MMEmotionCentre defaultCentre] setTheme:]即可修改商店和键盘样式。


##8. 设置APP UserId

开发者可以用`setUserId`方法设置App UserId，以便在后台统计时跟踪追溯单个用户的表情使用情况。
