//
//  LLChatViewController.m
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/4.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "LLChatViewController.h"
#import "LLInputView.h"
#import "LLChatSystemCell.h"
#import "LLChatTextMessageCell.h"
#import "LLChatVoiceMessageCell.h"
#import "LLChatImageMessageCell.h"
#import "LLChatVideoMessageCell.h"

@interface LLChatViewController ()<UITableViewDelegate,UITableViewDataSource,LLInputViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) LLInputView *inputView;
@property (nonatomic, strong) NSMutableArray *messageModels;
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) BOOL isShowName;
@property (nonatomic, assign) NSInteger recordDuration;
@property (nonatomic, strong) LLChatUserModel *userModel;
@property (nonatomic, strong) LLChatGroupModel *groupModel;

@end

@implementation LLChatViewController

- (instancetype)initWithUser:(LLChatUserModel *)userModel {
    self = [super init];
    if (self) {
        [self setConfig:userModel];
    }
    return self;
}

- (instancetype)initWithGroup:(LLChatGroupModel *)groupModel {
    self = [super init];
    if (self) {
        [self setConfig:groupModel];
    }
    return self;
}

- (instancetype)initWithSession:(LLChatSessionModel *)sessionModel {
    self = [super init];
    if (self) {
        [self setConfig:[[LLChatDBManager DBManager] selectChatModel:sessionModel]];
    }
    return self;
}

- (void)setConfig:(LLChatBaseModel *)model {
    self.title = @"消息";
    if ([model isKindOfClass:[LLChatUserModel class]]) {
        self.userModel = (LLChatUserModel *)model;
        self.isShowName = self.userModel.isShowName;
    }
    else {
        self.groupModel = (LLChatGroupModel *)model;
        self.isShowName = self.groupModel.isShowName;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.inputView];
    [self loadMessage:0];
    [self setRightItem];
}

- (void)loadMessage:(NSInteger)page {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (self.userModel) {
            self.messageModels = [[LLChatDBManager DBManager] messagesWithUser:self.userModel];
        }
        else {
            self.messageModels = [[LLChatDBManager DBManager] messagesWithGroup:self.groupModel];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
            [self tableViewScrollToBottom:NO];
        });
    });
}

#pragma mark - 模拟收到消息
- (void)setRightItem {
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"模拟收到消息" style:UIBarButtonItemStylePlain target:self action:@selector(rightItemClick)];
    self.navigationItem.rightBarButtonItem = item;
}

- (void)rightItemClick {
    static NSInteger msgType = 1;
    if (msgType == LLMessageTypeSystem) {
        NSString *timeMessage = [LLChatHelper timeFromDate:[NSDate date]];
        LLChatMessageModel *model = [LLChatMessageManager createSystemMessage:self.userModel
                                                                      message:timeMessage
                                                                     isSender:YES];
        [self receiveMessageModel:model];
    }
    else if (msgType == LLMessageTypeText) {
        LLChatMessageModel *model = [LLChatMessageManager createTextMessage:self.userModel
                                                                    message:@"[微笑]我收到了一条文本消息"
                                                                   isSender:NO];
        [self receiveMessageModel:model];
    }
    else if (msgType == LLMessageTypeImage) {
        //收到图片
        //原图和缩略图链接
        NSString *original = @"http://www.vasueyun.cn/llgit/llchat/2.jpg";
        NSString *thumbnail = @"http://www.vasueyun.cn/llgit/llchat/2_t.jpg";
        
        //图片下载的代码就不多写, 这里默认下载完成
        //原图
        UIImage *oriImage = [UIImage imageNamed:@"2.jpg"];
        //缩略图, 消息展示, 优化消息滑动时的卡顿
        UIImage *thumImage = [UIImage imageNamed:@"2_t.jpg"];
        
        //创建图片model
        LLChatMessageModel *model = [LLChatMessageManager createImageMessage:self.userModel
                                                                   thumbnail:thumbnail
                                                                    original:original
                                                                   thumImage:thumImage
                                                                    oriImage:oriImage
                                                                    isSender:NO];
        [self receiveMessageModel:model];
    }
    else if (msgType == LLMessageTypeVoice) {
        //接收到声音
        //声音地址
        NSString *voiceUrl = @"";
        
        //创建录音model
        NSInteger duration = arc4random()%60+1;
        LLChatMessageModel *model = [LLChatMessageManager createVoiceMessage:self.userModel
                                                                    duration:duration
                                                                    voiceUrl:voiceUrl
                                                                    isSender:NO];
        [self sendMessageModel:model];
    }
    else if (msgType == LLMessageTypeVideo) {
        //收到视频
        NSString *videoUrl = @"";
        //封面图链接
        NSString *coverUrl = @"http://www.vasueyun.cn/llgit/llchat/1_t.jpg";
        //下载封面图
        UIImage *coverImage = [UIImage imageNamed:@"1_t.jpg"];
        //创建视频model
        LLChatMessageModel *model = [LLChatMessageManager createVideoMessage:self.userModel
                                                                    videoUrl:videoUrl
                                                                    coverUrl:coverUrl
                                                                  coverImage:coverImage
                                                                    isSender:NO];
        [self sendMessageModel:model];
    }
    msgType = (msgType+1)%5;
}

#pragma mark - 发送消息
//文本消息
- (void)inputView:(LLInputView *)inputView sendMessage:(NSString *)message {
    //清空草稿
    [[LLChatDBManager DBManager] removeDraftWithModel:self.userModel];
    LLChatMessageModel *model = [LLChatMessageManager createTextMessage:self.userModel
                                                                message:message
                                                               isSender:YES];
    [self sendMessageModel:model];
}

//其他自定义消息, 如: 图片、视频、位置等等
- (void)inputView:(LLInputView *)inputView selectedType:(LLChatMoreType)type {
    if (type == LLChatMoreTypeImage) {
        //发送图片
        //选择图片的代码就不多写了, 这里假定已经选择了图片
        
        //原图,
        UIImage *oriImage = [UIImage imageNamed:@"1.jpg"];
        
        //缩略图, 消息展示, 优化消息滑动时的卡顿
        //将原图按照一定的算法压缩处理成缩略图, 这里直接使用外部生成的缩略图,
        UIImage *thumImage = [UIImage imageNamed:@"1_t.jpg"];
        
        //将图片上传到服务器, 图片消息只是把图片的链接发送过去, 接收端根据链接展示图片
        //上传图片的代码就不多写, 具体上传方式根据自身服务器api决定, 这里假定图片已经上传到服务器上了, 并且返回了两个链接, 原图和缩略图
        //原图和缩略图链接
        NSString *original = @"http://www.vasueyun.cn/llgit/llchat/1.jpg";
        NSString *thumbnail = @"http://www.vasueyun.cn/llgit/llchat/1_t.jpg";
        
        //创建图片model
        LLChatMessageModel *model = [LLChatMessageManager createImageMessage:self.userModel
                                                                   thumbnail:thumbnail
                                                                    original:original
                                                                   thumImage:thumImage
                                                                    oriImage:oriImage
                                                                    isSender:YES];
        [self sendMessageModel:model];
    }
    else if (type == LLChatMoreTypeVideo) {
        //发送视频
        //选择视频的代码就不多写了, 这里假定已经选择了视频
        //上传到服务器, 获取视频链接
        NSString *videoUrl = @"";
        
        //封面图
        UIImage *coverImage = [UIImage imageNamed:@"2_t.jpg"];
        
        //将封面图上传到服务器, 获取封面图链接
        NSString *coverUrl = @"http://www.vasueyun.cn/llgit/llchat/2_t.jpg";
        
        //创建视频model
        LLChatMessageModel *model = [LLChatMessageManager createVideoMessage:self.userModel
                                                                    videoUrl:videoUrl
                                                                    coverUrl:coverUrl
                                                                  coverImage:coverImage
                                                                    isSender:YES];
        [self sendMessageModel:model];
    }
    else if (type == LLChatMoreTypeLocation) {
        //发送定位 - 未实现
        
    }
    else if (type == LLChatMoreTypeTransfer) {
        //文件互传 - 未实现
        
    }
}

//文本变化
- (void)inputView:(LLInputView *)inputView didChangeText:(NSString *)text {
    //保存草稿
    [[LLChatDBManager DBManager] setDraft:text model:self.userModel];
}

//录音状态变化
- (void)inputView:(LLInputView *)inputView didChangeRecordType:(LLChatRecordType)type {
    if (type == LLChatRecordTypeTouchDown) {
        self.recordDuration = [LLChatHelper nowTimestamp]/1000;
        NSLog(@"开始录音");
    }
    else if (type == LLChatRecordTypeTouchCancel) {
        NSLog(@"取消录音");
    }
    else if (type == LLChatRecordTypeTouchFinish) {
        self.recordDuration = ([LLChatHelper nowTimestamp]/1000-self.recordDuration);
        if (self.recordDuration > 1) {
            //发送声音
            //录音的代码就不多写了, 这里假定已经录音
            
            //将录音上传到服务器, 获取录音链接
            NSString *voiceUrl = @"";
            
            //创建录音model
            LLChatMessageModel *model = [LLChatMessageManager createVoiceMessage:self.userModel
                                                                        duration:self.recordDuration
                                                                        voiceUrl:voiceUrl
                                                                        isSender:YES];
            [self sendMessageModel:model];
        }
        else {
            NSLog(@"录音时间过短");
        }
    }
    else {
        NSLog(@"手指滑动到按钮的外面了");
    }
}

//键盘状态变化
- (void)inputView:(LLInputView *)inputView willChangeFrameWithDuration:(CGFloat)duration isEditing:(BOOL)isEditing {
    self.isEditing = isEditing;
    
    CGFloat TContentH = self.tableView.contentSize.height;
    CGFloat tableViewH = self.tableView.bounds.size.height;
    CGFloat keyboardH = LLCHAT_SCREEN_HEIGHT-self.inputView.minY-LLCHAT_INPUT_H;
    
    CGFloat offsetY = 0;
    if (TContentH < tableViewH) {
        offsetY = TContentH+keyboardH-tableViewH;
        if (offsetY < 0) {
            offsetY = 0;
        }
    }
    else {
        offsetY = keyboardH;
    }
    
    CGRect TRect = self.tableView.frame;
    if (offsetY > 0) {
        TRect.origin.y = LLCHAT_NAV_TOP_H-offsetY+LLCHAT_BOTTOM_H;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.frame = TRect;
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messageModels.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:YES];
        }];
    }
    else {
        TRect.origin.y = LLCHAT_NAV_TOP_H;
        [UIView animateWithDuration:duration animations:^{
            self.tableView.frame = TRect;
        }];
    }
}

#pragma mark - private method
//发送消息
- (void)sendMessageModel:(LLChatMessageModel *)model {
    [self addMessageModel:model];
    
    //模拟消息发送中、发送成功、发送失败
    //根据需要可以将消息默认值设置为发送成功, 此处是为了演示效果
    NSInteger i = arc4random()%2;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (i == 0) {
            model.sendType = LLMessageSendTypeFailed;
        }
        else {
            model.sendType = LLMessageSendTypeSuccess;
        }
        if (self.userModel) {
            [[LLChatDBManager DBManager] updateMessageModel:model chatWithUser:self.userModel];
        }
        else {
            [[LLChatDBManager DBManager] updateMessageModel:model chatWithGroup:self.groupModel];
        }
        [self.tableView reloadData];
    });
    
    [LLChatNotificationManager postSessionNotification];
}

//收到消息
- (void)receiveMessageModel:(LLChatMessageModel *)model {
    [self addMessageModel:model];
    
    [LLChatNotificationManager postSessionNotification];
}

//消息存储
- (void)addMessageModel:(LLChatMessageModel *)model {
    [self.messageModels addObject:model];
    [_tableView reloadData];
    [self tableViewScrollToBottom:YES];
    
    if (self.userModel) {
        [[LLChatDBManager DBManager] insertMessage:model chatWithUser:self.userModel];
    }
    else {
        [[LLChatDBManager DBManager] insertMessage:model chatWithGroup:self.groupModel];
    }
}

- (void)tableViewScrollToBottom:(BOOL)animated {
    if (animated) {
        if (self.isEditing) {
            CGFloat TContentH = self.tableView.contentSize.height;
            CGFloat tableViewH = self.tableView.bounds.size.height;
            
            CGFloat keyboardH = LLCHAT_SCREEN_HEIGHT-self.inputView.minY-LLCHAT_INPUT_H;
            
            CGFloat offsetY = 0;
            if (TContentH < tableViewH) {
                offsetY = TContentH+keyboardH-tableViewH;
                if (offsetY < 0) {
                    offsetY = 0;
                }
            }
            else {
                offsetY = keyboardH;
            }
            
            if (offsetY > LLCHAT_BOTTOM_H) {
                CGRect TRect = self.tableView.frame;
                TRect.origin.y = LLCHAT_NAV_TOP_H-offsetY+LLCHAT_BOTTOM_H;
                [UIView animateWithDuration:0.25 animations:^{
                    self.tableView.frame = TRect;
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messageModels.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }];
            }
        }
        else {
            CGFloat TContentH = self.tableView.contentSize.height;
            CGFloat tableViewH = self.tableView.bounds.size.height;
            if (TContentH > tableViewH) {
                [UIView animateWithDuration:0.25 animations:^{
                    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messageModels.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
                }];
            }
        }
    }
    else {
        if (self.messageModels.count) {
            [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:(self.messageModels.count-1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
        }
    }
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.inputView chatResignFirstResponder];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.messageModels.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageModels.count) {
        LLChatMessageModel *model = [self.messageModels objectAtIndex:indexPath.row];
        [model cacheModelSize];
        if (model.msgType == LLMessageTypeSystem) {
            return model.modelH;
        }
        if (self.isShowName) {
            return model.modelH+45;
        }
        else {
            return model.modelH+32;
        }
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < self.messageModels.count) {
        
        LLChatBaseCell *cell;
        LLChatMessageModel *model = [self.messageModels objectAtIndex:indexPath.row];
        
        if (model.msgType == LLMessageTypeSystem) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"systemCell"];
            if (cell == nil) {
                cell = [[LLChatSystemCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"systemCell"];
            }
            [cell setConfig:model];
        }
        else if (model.msgType == LLMessageTypeText) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"textCell"];
            if (cell == nil) {
                cell = [[LLChatTextMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"textCell"];
            }
            [cell setConfig:model isShowName:self.isShowName];
        }
        else if (model.msgType == LLMessageTypeImage) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell"];
            if (cell == nil) {
                cell = [[LLChatImageMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"imageCell"];
            }
            [cell setConfig:model isShowName:self.isShowName];
        }
        else if (model.msgType == LLMessageTypeVoice) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"voiceCell"];
            if (cell == nil) {
                cell = [[LLChatVoiceMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"voiceCell"];
            }
            [cell setConfig:model isShowName:self.isShowName];
        }
        else if (model.msgType == LLMessageTypeVideo) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell"];
            if (cell == nil) {
                cell = [[LLChatVideoMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"videoCell"];
            }
            [cell setConfig:model isShowName:self.isShowName];
        }
        return cell;
    }
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"noDataCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"noDataCell"];
    }
    return cell;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        CGRect rect = self.view.bounds;
        rect.origin.y = LLCHAT_NAV_TOP_H;
        rect.size.height -= (LLCHAT_NAV_TOP_H+LLCHAT_INPUT_H+LLCHAT_BOTTOM_H);
        
        _tableView = [[UITableView alloc] initWithFrame:rect];
        _tableView.delegate = self;
        _tableView.dataSource = self;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            self.automaticallyAdjustsScrollViewInsets = NO;
        }
#else
        self.automaticallyAdjustsScrollViewInsets = NO;
#endif
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.tableFooterView = [UIView new];
        _tableView.backgroundColor = [UIColor colorWithRed:240/255. green:240/255. blue:240/255. alpha:1];
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (LLInputView *)inputView {
    if (_inputView == nil) {
        _inputView = [[LLInputView alloc] init];
        _inputView.delegate = self;
        [_inputView setText:[[LLChatDBManager DBManager] draftWithModel:self.userModel]];
    }
    return _inputView;
}

- (NSMutableArray *)messageModels {
    if (_messageModels == nil) {
        _messageModels = [[NSMutableArray alloc] initWithCapacity:0];
    }
    return _messageModels;
}

- (void)dealloc {
    NSLog(@"释放了==%@",NSStringFromClass([self class]));
}

@end
