//
//  LLEmojisKeyboard.m
//  LLChat
//
//  Created by WangZhaomeng on 2018/9/5.
//  Copyright © 2018年 WangZhaomeng. All rights reserved.
//

#import "LLEmojisKeyboard.h"
#import "LLBlankCell.h"
#import "LLEmojisCell.h"
#import "LLDeleteCell.h"
#import "LLEmoticonCell.h"
#import "LLHorizontalLayout.h"

#define key_rows  3
#define key_nums  7
@interface LLEmojisKeyboard ()<UICollectionViewDelegate,UICollectionViewDataSource>

@end

@implementation LLEmojisKeyboard {
    NSMutableArray *_btns;
    UIButton *_selectedBtn;
    NSInteger _emojisSection;
    NSMutableArray *_emoticons;
    UICollectionView *_collectionView;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        CGFloat key_itemW = 45;
        CGFloat spcing = (320-key_itemW*key_nums)/(key_nums+1);
        LLHorizontalLayout *horLayout = [[LLHorizontalLayout alloc] initWithSpacing:spcing rows:key_rows nums:key_nums];
        
        CGRect rect = self.bounds;
        rect.size.height -= (40+LLCHAT_BOTTOM_H);
        _collectionView = [[UICollectionView alloc] initWithFrame:rect collectionViewLayout:horLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.backgroundColor = [UIColor whiteColor];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
        if (@available(iOS 11.0, *)) {
            _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
#endif
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[LLBlankCell class] forCellWithReuseIdentifier:@"blank"];
        [_collectionView registerClass:[LLEmojisCell class] forCellWithReuseIdentifier:@"emojis"];
        [_collectionView registerClass:[LLDeleteCell class] forCellWithReuseIdentifier:@"delete"];
        [_collectionView registerClass:[LLEmoticonCell class] forCellWithReuseIdentifier:@"emoticon"];
        [self addSubview:_collectionView];
        
        UIColor *themeColor = [UIColor colorWithRed:34/255. green:207/255. blue:172/255. alpha:1];
        UIView *toolView = [[UIView alloc] initWithFrame:CGRectMake(0, _collectionView.maxY, frame.size.width, 40+LLCHAT_BOTTOM_H)];
        toolView.backgroundColor = [UIColor colorWithRed:220/255. green:220/255. blue:220/255. alpha:1];
        [self addSubview:toolView];
        
        _btns = [[NSMutableArray alloc] init];
        NSArray *names = @[@"默认",@"浪小花",@"emojis"];
        for (NSInteger i = 0; i < names.count; i ++) {
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(i*60, 0, 60, 40);
            btn.titleLabel.font = [UIFont systemFontOfSize:14];
            [btn setTitle:[names objectAtIndex:i] forState:UIControlStateNormal];
            [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [btn setTitleColor:themeColor forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(toolBtnClick:) forControlEvents:UIControlEventTouchUpInside];
            [toolView addSubview:btn];
            [_btns addObject:btn];
            if (i == 0) {
                _selectedBtn = btn;
                _selectedBtn.selected = YES;
            }
        }
        
        UIButton *sendBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        sendBtn.frame = CGRectMake(frame.size.width-80, 0, 80, 40);
        sendBtn.titleLabel.font = [UIFont systemFontOfSize:13];
        sendBtn.backgroundColor = themeColor;
        [sendBtn setTitle:@"发送" forState:UIControlStateNormal];
        [sendBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [sendBtn addTarget:self action:@selector(sendBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        [toolView addSubview:sendBtn];
        
        //1、初始化
        _emoticons = [[NSMutableArray alloc] initWithCapacity:0];
        //2、加载表情
        //默认表情
        NSString *path1 = [[NSBundle mainBundle] pathForResource:@"LLEmoticon1" ofType:@"plist"];
        NSDictionary *dic1 = [[NSDictionary alloc] initWithContentsOfFile:path1];
        [_emoticons addObject:dic1];
        //浪小花
        NSString *path2 = [[NSBundle mainBundle] pathForResource:@"LLEmoticon2" ofType:@"plist"];
        NSDictionary *dic2 = [[NSDictionary alloc] initWithContentsOfFile:path2];
        [_emoticons addObject:dic2];
        //emojis
        _emojisSection = _emoticons.count;
        NSString *peoplePath = [[NSBundle mainBundle] pathForResource:@"LLEmojis" ofType:@"plist"];
        NSDictionary *emojis = [NSDictionary dictionaryWithContentsOfFile:peoplePath];
        NSArray *peopleEmojis = [emojis objectForKey:@"Default"];
        //3、添加数据, 刷新表
        [_emoticons addObject:peopleEmojis];
        [_collectionView reloadData];
    }
    return self;
}

#define mark - UICollectionViewDataSource,UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return _emoticons.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    //emojis表情
    if (section == _emojisSection) {
        NSArray *emojis = [_emoticons objectAtIndex:section];
        return [self totalCount:emojis.count];
    }
    else {
        //图片表情
        NSDictionary *dic = [_emoticons objectAtIndex:section];
        NSArray *emoticons = [dic objectForKey:@"emoticons"];
        return [self totalCount:emoticons.count];
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isDelete:indexPath.item]) {
        LLDeleteCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"delete" forIndexPath:indexPath];
        return cell;
    }
    else {
        //emojis表情
        if (indexPath.section == _emojisSection) {
            NSArray *emojis = [_emoticons objectAtIndex:indexPath.section];
            NSInteger index = [self trueIndex:indexPath.item];
            if (index < emojis.count) {
                NSString *text = [emojis objectAtIndex:index];
                LLEmojisCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emojis" forIndexPath:indexPath];
                [cell setConfig:text];
                return cell;
            }
            else {
                LLBlankCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"blank" forIndexPath:indexPath];
                return cell;
            }
        }
        else {
            //图片表情
            NSDictionary *dic = [_emoticons objectAtIndex:indexPath.section];
            NSArray *emoticons = [dic objectForKey:@"emoticons"];
            NSInteger index = [self trueIndex:indexPath.item];
            if (index < emoticons.count) {
                NSDictionary *dic = [emoticons objectAtIndex:index];
                LLEmoticonCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"emoticon" forIndexPath:indexPath];
                [cell setConfig:dic];
                return cell;
            }
            else {
                LLBlankCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"blank" forIndexPath:indexPath];
                return cell;
            }
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isDelete:indexPath.item]) {
        if ([self.delegate respondsToSelector:@selector(emojisKeyboardDelete)]) {
            [self.delegate emojisKeyboardDelete];
        }
    }
    else {
        NSString *text;
        if (indexPath.section == _emojisSection) {
            //emojis表情
            NSArray *emojis = [_emoticons objectAtIndex:indexPath.section];
            NSInteger index = [self trueIndex:indexPath.item];
            if (index < emojis.count) {
                text = [emojis objectAtIndex:index];
            }
        }
        else {
            //图片表情
            NSDictionary *dic = [_emoticons objectAtIndex:indexPath.section];
            NSArray *emoticons = [dic objectForKey:@"emoticons"];
            NSInteger index = [self trueIndex:indexPath.item];
            if (index < emoticons.count) {
                NSDictionary *dic = [emoticons objectAtIndex:index];
                text = [dic objectForKey:@"chs"];
            }
        }
        if ([self.delegate respondsToSelector:@selector(emojisKeyboardSendText:)]) {
            [self.delegate emojisKeyboardSendText:text];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    NSInteger index = scrollView.contentOffset.x/LLCHAT_SCREEN_WIDTH;
    NSInteger section = [self currectSection:index];
    NSInteger page = [self currectPage:index];
    UIButton *btn = [_btns objectAtIndex:section];
    if (btn.isSelected) return;
    [self selectedBtn:btn];
}

- (void)toolBtnClick:(UIButton *)btn {
    if (btn.isSelected) return;
    [self selectedBtn:btn];
    NSInteger index = [self totalPageBeforeSection:btn.tag];
    [_collectionView setContentOffset:CGPointMake(LLCHAT_SCREEN_WIDTH*index, 0) animated:NO];
}

- (void)selectedBtn:(UIButton *)btn {
    _selectedBtn.selected = NO;
    _selectedBtn = btn;
    _selectedBtn.selected = YES;
}

- (void)sendBtnClick:(UIButton *)btn {
    if ([self.delegate respondsToSelector:@selector(emojisKeyboardSend)]) {
        [self.delegate emojisKeyboardSend];
    }
}

//是否是删除键
- (BOOL)isDelete:(NSInteger)index {
    NSInteger c = key_rows*key_nums;
    return ((index+1)%c == 0);
}

//数组中的正确索引
- (NSInteger)trueIndex:(NSInteger)index {
    NSInteger c = key_rows*key_nums;
    //已经加了的删除键个数
    NSInteger count = (index+1)/c;
    return (index-count);
}

//区item总个数
- (NSInteger)totalCount:(NSInteger)count {
    NSInteger c = key_rows*key_nums;
    //一共需要的删除键个数
    NSInteger dc = ceil(count*1.0/(c-1));
    return dc*c;
}

//区总页数
- (NSInteger)totalPage:(NSInteger)count {
    NSInteger c = key_rows*key_nums;
    return ceil(count*1.0/(c-1));
}

//获取当前区数
- (NSInteger)currectSection:(NSInteger)index {
    NSInteger lastPage = 0;
    for (NSInteger i = 0; i < _emoticons.count ; i ++) {
        if (i == _emojisSection) {
            NSArray *emojis = [_emoticons objectAtIndex:i];
            lastPage = [self totalPage:emojis.count]+lastPage;
        }
        else {
            //图片表情
            NSDictionary *dic = [_emoticons objectAtIndex:i];
            NSArray *emoticons = [dic objectForKey:@"emoticons"];
            lastPage = [self totalPage:emoticons.count]+lastPage;
        }
        if (index < lastPage) {
            return i;
        }
    }
    return 0;
}

//获取在当前区中的页数
- (NSInteger)currectPage:(NSInteger)index {
    NSInteger page = [self currectSection:index];
    NSInteger lastPage = 0;
    for (NSInteger i = 0; i < page ; i ++) {
        if (i == _emojisSection) {
            NSArray *emojis = [_emoticons objectAtIndex:i];
            lastPage = [self totalPage:emojis.count]+lastPage;
        }
        else {
            //图片表情
            NSDictionary *dic = [_emoticons objectAtIndex:i];
            NSArray *emoticons = [dic objectForKey:@"emoticons"];
            lastPage = [self totalPage:emoticons.count]+lastPage;
        }
    }
    return index-lastPage;
}

//指定区之前有多少页数
- (NSInteger)totalPageBeforeSection:(NSInteger)section {
    NSInteger lastPage = 0;
    for (NSInteger i = 0; i < section ; i ++) {
        if (i == _emojisSection) {
            NSArray *emojis = [_emoticons objectAtIndex:i];
            lastPage = [self totalPage:emojis.count]+lastPage;
        }
        else {
            //图片表情
            NSDictionary *dic = [_emoticons objectAtIndex:i];
            NSArray *emoticons = [dic objectForKey:@"emoticons"];
            lastPage = [self totalPage:emoticons.count]+lastPage;
        }
    }
    return lastPage;
}

@end
