//
//  MissIMFrame.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMFrame.h"
#import "MissIMData.h"

@implementation MissIMFrame

-(void)setData:(MissIMData *)data
{
    _data = data;
    CGFloat mainScreenWidth = [UIScreen mainScreen].bounds.size.width;
    
    //设置时间
    CGFloat timeY = MissMargin;
    CGSize timeSize = [_data.sendTime sizeWithFont:ChatTimeFont constrainedToSize:CGSizeMake(300, 100) lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat timeX = MissMargin;
    
    
    //计算头像的x位置
    CGFloat iconX = MissMargin;
    //如果是自己发送的消息
    if (_data.from == kMISSIMFROMME) {
        //屏幕总宽度 减去 间隔 ＋ 图片宽  头像在右边
        iconX = mainScreenWidth - (MissMargin + MissIconWidthAndHeight);
        timeX = mainScreenWidth - timeSize.width - (MissMargin*2);
    }
    _timeFrame = CGRectMake(timeX, timeY, timeSize.width, timeSize.height);
    //计算头像的y位置，时间的最大y值加间隔
    CGFloat iconY = CGRectGetMaxY(_timeFrame) + MissMargin;
    _iconFrame = CGRectMake(iconX, iconY, MissIconWidthAndHeight, MissIconWidthAndHeight);
    
    CGFloat nameY = iconY + MissIconWidthAndHeight + MissMargin;
    //计算用户名
    _nameFrame = CGRectMake(iconX, nameY, MissIconWidthAndHeight, 20);
    
    //计算内容的位置
    CGFloat contentX = CGRectGetMaxX(_iconFrame) + MissMargin;
    CGFloat contentY = iconY;
    CGSize contentSize;
    switch (_data.type) {
        case kMISSIMTYPETEXT:
            contentSize = [_data.text sizeWithFont:ChatContentFont  constrainedToSize:CGSizeMake(MissContentWidth, CGFLOAT_MAX) lineBreakMode:NSLineBreakByWordWrapping];
            break;
            
        default:
            contentSize = CGSizeMake(MissPickerImageWidthAndHeight, MissPickerImageWidthAndHeight);
            break;
    }
    if (_data.from == kMISSIMFROMME) {
        contentX = iconX - contentSize.width - MissContentLeft - MissContentRight - MissMargin;
    }
    
    _conFrame = CGRectMake(contentX, contentY, contentSize.width + MissContentLeft + MissContentRight, contentSize.height + MissContentTop + MissContentBottom);
    _cellHeight = MAX(CGRectGetMaxY(_conFrame), CGRectGetMaxY(_nameFrame)) + MissMargin;
}

-(void)dealloc
{
    NSLog(@"MissIMFrame  内存释放");
}

@end
