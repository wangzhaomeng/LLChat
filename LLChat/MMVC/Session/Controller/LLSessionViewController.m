//
//  LLSessionViewController.m
//  LLChat
//
//  Created by WangZhaomeng on 2018/8/31.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "LLSessionViewController.h"
#import "LLSessionTableViewCell.h"

@interface LLSessionViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *sessions;
@property (nonatomic, strong) UITableView *tableView;

@end

@implementation LLSessionViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.title = @"消息";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupUI];
    [self loadSession];
}

- (void)setupUI {
    [self.view addSubview:self.tableView];
}

- (void)loadSession {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        self.sessions = [[LLChatDBManager DBManager] sessions];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    });
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.row < self.sessions.count) {
        LLChatSessionModel *session = [self.sessions objectAtIndex:indexPath.row];
        
        LLChatViewController *chatVC = [[LLChatViewController alloc] initWithSession:session];
        chatVC.hidesBottomBarWhenPushed = YES;
        [self.navigationController pushViewController:chatVC animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.sessions.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 70;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    LLSessionTableViewCell *cell = (LLSessionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[LLSessionTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    if (indexPath.row < self.sessions.count) {
        LLChatSessionModel *session = [self.sessions objectAtIndex:indexPath.row];
        [cell setConfig:session];
    }
    return cell;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row < self.sessions.count) {
        LLChatSessionModel *session = [self.sessions objectAtIndex:indexPath.row];
        UITableViewRowAction *deleteAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDefault title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
            [self.sessions removeObject:session];
            [self.tableView reloadData];
            [[LLChatDBManager DBManager] deleteSessionModel:session.sid];
        }];
        deleteAction.backgroundColor = [UIColor redColor];
        return @[deleteAction];
    }
    return nil;
}

#pragma mark - getter
- (UITableView *)tableView {
    if (_tableView == nil) {
        CGRect rect = self.view.bounds;
        rect.origin.y = LLCHAT_NAV_TOP_H;
        rect.size.height -= (LLCHAT_NAV_TOP_H+LLCHAT_BAR_BOT_H);
        
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
    }
    return _tableView;
}

@end
