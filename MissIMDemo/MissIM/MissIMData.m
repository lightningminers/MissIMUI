//
//  MissIMData.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import "MissIMData.h"

@interface MissIMData()

@property(nonatomic,strong) NSDateFormatter *formatter;

@end

@implementation MissIMData

-(NSDateFormatter *)formatter
{
    if (!_formatter) {
        _formatter = [[NSDateFormatter alloc] init];
        [_formatter setDateFormat:@"YYYY年M月dd日 HH时mm分ss秒"];
    }
    return _formatter;
}

-(instancetype)initWithMissMessageDataSource:(NSDictionary *)dict isNotHistory:(BOOL)isNotHistory
{
    self = [super init];
    if (self) {
        self.name = dict[@"name"];
        self.iconURL = dict[@"iconURL"];
        self.iconImage = dict[@"iconImage"];
        self.userId = dict[@"userId"];
        if (isNotHistory) {
            self.sendTime = [self createDateNowString];
        }else{
            int64_t timeId = [dict[@"sendTime"] longLongValue];
            self.sendTime = [self createDateHistoryString:timeId];
        }
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

-(NSString *)createDateNowString
{
    NSString *nowTime = [self.formatter stringFromDate:[NSDate date]];
    return nowTime;
}

-(NSString *)createDateHistoryString:(int64_t)timeId
{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:timeId/1000.0];
    NSString *historyTime = [self.formatter stringFromDate:date];
    return historyTime;
    
}

-(void)dealloc
{
    NSLog(@"MissIMData 内存释放");
}

@end
