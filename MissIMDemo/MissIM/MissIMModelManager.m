//
//  MissIMModelManager.m
//  missfresh
//
//  Created by xiangwenwen on 15/4/3.
//
//

#import <AVOSCloudIM/AVOSCloudIM.h>
#import <CommonCrypto/CommonDigest.h>
#import "MissIMModelManager.h"
#import "MissIMFrame.h"
#import "MissIMData.h"

@interface MissIMModelManager()

@end

@implementation MissIMModelManager

-(instancetype)initWithdataSource:(NSDictionary *)info
{
    self = [super init];
    if (self) {
        self.dataSource = [[NSMutableArray alloc] init];
        self.basePath = NSHomeDirectory();
        self.documentsPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
        self.iconImageDirPath = [self.documentsPath stringByAppendingPathComponent:@"Photos"];
        self.serviceImage = [UIImage imageNamed:@"service-icon.jpg"];
        self.serviceName = @"service";
        self.userId = info[@"userId"];
        self.userName = info[@"nickname"];
        NSString *recordPlist = [NSString stringWithFormat:@"MissIM%@.plist",self.userId];
        self.MissIMPlistPath = [self.documentsPath stringByAppendingPathComponent:recordPlist];
        self.messageNumber = 0;
        
        /*
            用户头像检查逻辑
         */
        
        NSURL *userIconURL = [NSURL URLWithString:info[@"iconUrl"]];
        self.userImage = [UIImage imageWithData:[NSData dataWithContentsOfURL:userIconURL]];

        //对目录，以及plist文件进行检查与创建
        NSFileManager *manager = [[NSFileManager alloc] init];
        
        BOOL isdir = [manager fileExistsAtPath:self.iconImageDirPath];
        if (!isdir) {
            [manager createDirectoryAtPath:self.iconImageDirPath withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        BOOL isPlist = [manager fileExistsAtPath:self.MissIMPlistPath];
        if (!isPlist) {
            //如果不存在，创建这个缓存目录
            [manager createFileAtPath:self.MissIMPlistPath contents:nil attributes:nil];
            self.isHistory = NO;
        }else{
            NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:self.MissIMPlistPath];
            NSString *conversationId = plistData[@"conversationId"];
            if (plistData) {
                if (conversationId && conversationId.length > 0) {
                    self.messageId = plistData[@"messageId"];
                    self.timeId = [plistData[@"timeId"] longLongValue];
                    self.conversationId = conversationId;
                    self.messageNumber = [plistData[@"messageNumber"] longValue];
                    self.isHistory = YES;
                }
            }else{
                self.isHistory = NO;
            }
        }
        
    }
    return self;
}

-(void)addMissIMDataSource:(NSDictionary *)dict ordered:(BOOL)Ordered
{
    
    //初始化视图坐标对象
    MissIMFrame *frame = [[MissIMFrame alloc] init];
    NSMutableDictionary *dataDict = [NSMutableDictionary dictionaryWithDictionary:dict];
    /*
        未来可扩展，进一步处理复杂数据
     */
    dataDict[@"userId"] = self.userId;
    //设置发送者
    if ([dataDict[@"from"] integerValue] == kMISSIMFROMME) {
        //自己发送的消息
        dataDict[@"name"] = self.userName;
        dataDict[@"iconImage"] = self.userImage;
    }else{
        //别人发送过来的消息
        dataDict[@"name"] = self.serviceName;
        dataDict[@"iconImage"] = self.serviceImage;
    }
    //把数据存储到模型对象中
    MissIMData *data = [[MissIMData alloc] initWithMissMessageDataSource:dataDict isNotHistory:Ordered];
    //把模型对象存储在视图坐标对象中
     frame.data = data;
    //把视图坐标对象添加到dataSource中给外部使用
    if (Ordered) {
        [self.dataSource addObject:frame];
    }else{
        [self.dataSource insertObject:frame atIndex:0];
    }
    
}

-(MissIMFrame *)getRandomItemsToDataSource:(NSInteger)number
{
    return [self.dataSource objectAtIndex:number];
}

-(BOOL)writeToMissIMPlistFile:(NSString *)messageId conversationId:(NSString *)conversationId timeId:(int64_t)timestamp messageNumber:(NSInteger)messageNumber
{
    if (messageId != nil && messageId.length > 0) {
        NSNumber *timeId = [NSNumber numberWithLongLong:timestamp];
        NSNumber *messageCount = [NSNumber numberWithLong:messageNumber];
        NSDictionary *dataSource = @{@"messageId":messageId,@"timeId":timeId,@"messageNumber":messageCount,@"conversationId":conversationId};
        BOOL isOK = [dataSource writeToFile:_MissIMPlistPath atomically:YES];
        if (isOK) {
            NSLog(@"写入MissIM%@.plist文件成功",self.userId);
        }
        return isOK;
    }
    return NO;
}

-(void)parseHistoryMessage:(NSArray *)historyMessageArray ordered:(BOOL)Ordered
{
    for (AVHistoryMessage *message in historyMessageArray) {
        NSMutableDictionary *historyMes = [[NSMutableDictionary alloc] init];
        NSString *fromPeerId = message.fromPeerId;
        NSString *payload = message.payload;
        historyMes[@"sendTime"] = [NSNumber numberWithLongLong:message.timestamp];
        //判断是自己发的还是别人发的
        if ([fromPeerId isEqualToString:self.userId]) {
            historyMes[@"from"] = @(kMISSIMFROMME);
        }else{
            historyMes[@"from"] = @(kMISSIMFROMOTHER);
        }
        
        //利用JSON的error处理机制，分文本还是图片
        if (payload) {
            NSError *JSONERROR;
            NSData *JSONDATA = [payload dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *JSON = [NSJSONSerialization JSONObjectWithData:JSONDATA options:NSJSONReadingMutableLeaves error:&JSONERROR];
            if (!JSONERROR) {
                NSDictionary *dataJSON = [NSDictionary dictionaryWithDictionary:JSON[@"_lcfile"]];
                historyMes[@"type"] = @(kMISSIMTYPEIMAGE);
                NSURL *downloadURL = [NSURL URLWithString:dataJSON[@"url"]];
                historyMes[@"pickerImage"] = [UIImage imageWithData:[NSData dataWithContentsOfURL:downloadURL]];
            }else{
                //文本
                historyMes[@"type"] = @(kMISSIMTYPETEXT);
                historyMes[@"text"] = payload;
            }
            NSLog(@"payload---%@",payload);
        }
        [self addMissIMDataSource:historyMes ordered:Ordered];
    }
}
/*
    根据用户Id去下载头像
 
 **/

-(NSString *)createImageFilePath
{
    NSString *pathPrefix = [self md5:[NSString stringWithFormat:@"%d%@",(arc4random() * 100),self.userId]];
    NSString *path = [pathPrefix stringByAppendingString:@".jpg"];
    NSString *imageFilePath = [self.iconImageDirPath stringByAppendingPathComponent:path];
    return imageFilePath;
}

-(NSString *) md5: (NSString *) inPutText
{
    const char *cStr = [inPutText UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, strlen(cStr), result);
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

-(void)dealloc
{
    NSLog(@"MissIMModelManager 内存释放");
}

@end
