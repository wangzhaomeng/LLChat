//
//  LLSessionTableViewCell.m
//  LLChat
//
//  Created by WangZhaomeng on 2019/4/30.
//  Copyright © 2019 WangZhaomeng. All rights reserved.
//

#import "LLSessionTableViewCell.h"

#define rgb(r,g,b) [UIColor colorWithRed:r/255.0f green:g/255.0f blue:b/255.0f alpha:1.0]
@implementation LLSessionTableViewCell {
    UIImageView *_avatarImageView;
    UIView *_badgeView;
    UILabel *_badgeLabel;
    UILabel *_nameLabel;
    UILabel *_messageLabel;
    UILabel *_timeLabel;
    UIImageView *_notiImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 11, 48, 48)];
        [_avatarImageView setLLCornerRadius:5];
        
        [self addSubview:_avatarImageView];
        
        _badgeView = [[UIView alloc] initWithFrame:CGRectMake(_avatarImageView.maxX-5, _avatarImageView.minY-5, 10, 10)];
        _badgeView.backgroundColor = rgb(250, 81, 81);
        
        [_badgeView setLLCornerRadius:5];
        _badgeView.hidden = YES;
        [self addSubview:_badgeView];
        
        _badgeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_avatarImageView.maxX-9, _avatarImageView.minY-9, 18, 18)];
        _badgeLabel.font = [UIFont systemFontOfSize:12];
        _badgeLabel.textColor = [UIColor whiteColor];
        _badgeLabel.textAlignment = NSTextAlignmentCenter;
        _badgeLabel.backgroundColor = rgb(250, 81, 81);
        [_badgeLabel setLLCornerRadius:9];
        _badgeLabel.hidden = YES;
        [self addSubview:_badgeLabel];
        
        CGFloat timeW = 100;
        CGFloat nickX = _avatarImageView.maxX+15;
        CGFloat nimeW = LLCHAT_SCREEN_WIDTH-nickX-timeW-15;
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(nickX, 13, nimeW, 20)];
        _nameLabel.font = [UIFont systemFontOfSize:16];
        _nameLabel.textColor = [UIColor darkTextColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_nameLabel];
        
        _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(nickX, _nameLabel.maxY+7, nimeW+60, 15)];
        _messageLabel.font = [UIFont systemFontOfSize:13];
        _messageLabel.textColor = rgb(160, 160, 160);
        _messageLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_messageLabel];
        
        _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(_nameLabel.maxX, 15, timeW, 15)];
        _timeLabel.font = [UIFont systemFontOfSize:12];
        _timeLabel.textColor = [UIColor grayColor];
        _timeLabel.textAlignment = NSTextAlignmentRight;
        [self addSubview:_timeLabel];
        
        _notiImageView = [[UIImageView alloc] initWithFrame:CGRectMake(LLCHAT_SCREEN_WIDTH-32, _avatarImageView.maxY-20, 17, 17)];
        _notiImageView.hidden = YES;
        [self addSubview:_notiImageView];
    }
    return self;
}

- (void)setConfig:(LLChatSessionModel *)model {
    
    BOOL isIgnore = model.isIgnore;
    NSInteger lastTimestamp = model.lastTimestamp;
    NSString *unreadNum = model.unreadNum;
    NSString *lastMsg = model.lastMsg;
    
    if (isIgnore) {
        //消息免打扰
        _notiImageView.hidden = NO;
        _badgeLabel.text = @"";
        _badgeLabel.hidden = YES;
        if (unreadNum.integerValue > 0) {
            _badgeView.hidden = NO;
            if (unreadNum.integerValue > 1) {
                lastMsg = [NSString stringWithFormat:@"[%@条] %@",unreadNum,lastMsg];
            }
        }
        else {
            _badgeView.hidden = YES;
        }
    }
    else {
        //消息提醒
        _notiImageView.hidden = YES;
        if (unreadNum.integerValue <= 0) {
            _badgeLabel.text = @"";
            _badgeView.hidden = YES;
            _badgeLabel.hidden = YES;
        }
        else {
            if (unreadNum.integerValue < 10) {
                _badgeLabel.frame = CGRectMake(_avatarImageView.maxX-9, _avatarImageView.minY-9, 18, 18);
            }
            else if (unreadNum.integerValue < 100) {
                _badgeLabel.frame = CGRectMake(_avatarImageView.maxX-17, _avatarImageView.minY-9, 26, 18);
            }
            else {
                unreadNum = @"···";
                _badgeLabel.frame = CGRectMake(_avatarImageView.maxX-21, _avatarImageView.minY-9, 30, 18);
            }
            _badgeLabel.text = unreadNum;
            _badgeView.hidden = YES;
            _badgeLabel.hidden = NO;
        }
    }
    
    [[LLChatImageCache imageCache] getImageWithUrl:model.avatar isUseCatch:YES completion:^(UIImage *image) {
        _avatarImageView.image = image;
    }];
    _notiImageView.image = [UIImage imageNamed:@"ll_chat_bell_not"];
    _nameLabel.text = model.name;
    _messageLabel.text = lastMsg;
    _timeLabel.text = [LLChatHelper timeFromTimeStamp:[NSString stringWithFormat:@"%@",@(lastTimestamp)]];
    
    if (_notiImageView.hidden) {
        _messageLabel.LLWidth = _nameLabel.LLWidth+100;
    }
    else {
        _messageLabel.LLWidth = _nameLabel.LLWidth+80;
    }
}

@end
