//
//  MissIMData.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMData.h"

@interface MissIMData()


@end

@implementation MissIMData

-(instancetype)initWithMissMessageDataSource:(NSDictionary *)dict isNotHistory:(BOOL)isNotHistory
{
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.iconURL = dict[@"iconURL"];
        self.iconImage = dict[@"iconImage"];
        self.userId = dict[@"userId"];
        self.sendTime = dict[@"sendTime"];
        
        //设置发送者
        if ([dict[@"from"] integerValue] == kMISSIMFROMME) {
            //自己发送的消息
            self.from = kMISSIMFROMME;
        }else{
            //别人发送过来的消息
            self.from = kMISSIMFROMOTHER;
        }
        
        //消息的类型
        switch ([dict[@"type"] integerValue]) {
            case kMISSIMTYPETEXT:
                    self.text = dict[@"text"];
                    self.type = kMISSIMTYPETEXT;
                break;
            default:
                    self.pickerImage = dict[@"pickerImage"];
                    self.type = kMISSIMTYPEIMAGE;
                break;
        }
    }
    return self;
}

-(void)dealloc
{
    NSLog(@"MissIMData 内存释放");
}

@end
