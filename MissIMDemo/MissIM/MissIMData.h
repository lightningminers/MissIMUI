//
//  MissIMData.h
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum{
    
    kMISSIMTYPETEXT = 1,  //文本类型
    kMISSIMTYPEIMAGE  //图片类型
    
}MISSMESSAGETYPE;

typedef enum{
    
    kMISSIMFROMME = 1, //自己发的
    kMISSIMFROMOTHER //别人发的
    
}MISSMESSAGEFROM;

@interface MissIMData : NSObject

@property(nonatomic,copy) NSString *name; //用户名称
@property(nonatomic,copy) NSString *iconURL; //用户头像URL
@property(nonatomic,strong) UIImage *iconImage; //用户头像 
@property(nonatomic,copy) NSString *userId; //用户id
@property(nonatomic,copy) NSString *sendTime; //消息发送时间
@property(nonatomic,copy) NSString *text; //文本消息
@property(nonatomic,strong) UIImage *pickerImage; //图片
@property(nonatomic,assign) MISSMESSAGETYPE type; //消息的类型
@property(nonatomic,assign) MISSMESSAGEFROM from; //自己发还是别人发

-(instancetype)initWithMissMessageDataSource:(NSDictionary *)dict isNotHistory:(BOOL)isNotHistory;


@end
