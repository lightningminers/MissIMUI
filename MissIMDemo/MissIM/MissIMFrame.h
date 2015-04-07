//
//  MissIMFrame.h
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class  MissIMData;

static NSInteger MissMargin = 10; //间隔
static NSInteger MissIconWidthAndHeight = 44; //头像宽高height、width
static NSInteger MissPickerImageWidthAndHeight = 200; //图片宽高
static NSInteger MissContentWidth = 200; //内容宽度
static NSInteger MissTimeMarginWidth = 15; //时间文本与边框间隔宽度方向
static NSInteger MissTimeMarginHeight = 10; //时间文本与边框间隔高度方向
static NSInteger MissContentTop = 15; //文本内容与按钮上边缘间隔
static NSInteger MissContentLeft = 25; //文本内容与按钮左边缘间隔
static NSInteger MissContentBottom = 15; //文本内容与按钮下边缘间隔
static NSInteger MissContentRight = 15;  //文本内容与按钮右边缘间隔


#define ChatTimeFont [UIFont systemFontOfSize:11]   //时间字体
#define ChatContentFont [UIFont systemFontOfSize:14]//内容字体

@interface MissIMFrame : NSObject

@property(nonatomic,strong) MissIMData *data;


@property(nonatomic,assign,readonly) CGRect nameFrame; //名称的坐标
@property(nonatomic,assign,readonly) CGRect timeFrame; //时间的坐标
@property(nonatomic,assign,readonly) CGRect iconFrame; //头像的坐标
@property(nonatomic,assign,readonly) CGRect headFrame; //头部视图的坐标
@property(nonatomic,assign,readonly) CGRect conFrame; //内容区域视图的坐标
@property(nonatomic,assign,readonly) CGFloat cellHeight; //行高


@end
