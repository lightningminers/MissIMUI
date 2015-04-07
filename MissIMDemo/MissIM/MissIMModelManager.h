//
//  MissIMModelManager.h
//  missfresh
//
//  Created by xiangwenwen on 15/4/3.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class MissIMFrame;

@protocol MissIMModelManagerDelegate <NSObject>

@optional

@end


@interface MissIMModelManager : NSObject

@property(nonatomic,strong) NSMutableArray *dataSource;
@property(nonatomic,copy) NSString *basePath; //应用Home根路径
@property(nonatomic,copy) NSString *documentsPath; //应用Documents根路径
@property(nonatomic,copy) NSString *MissIMPlistPath; //MissIM plist 缓存文件路径
@property(nonatomic,copy) NSString *iconImageDirPath; //应用缓存用户头像的目录路径

//一次性的，所以放在模型管理类中
@property(nonatomic,copy) NSString *serviceName; //客服名称
@property(nonatomic,strong) UIImage *serviceImage;//客服头像
@property(nonatomic,strong) UIImage *userImage;//用户头像
@property(nonatomic,copy) NSString *userName; //用户名称
@property(nonatomic,copy) NSString *userId; //用户Id

//中间转化
@property(nonatomic,copy) NSString *messageId; //查询历史纪录的Id
@property(nonatomic,assign) int64_t timeId; //查询历史纪录的时间Id
@property(nonatomic,copy) NSString *conversationId; //唯一的对话Id
@property(nonatomic,assign) NSInteger messageNumber; //纪录一个客户端聊天的数目
@property(nonatomic,assign) BOOL isHistory;

@property(nonatomic,assign) id<MissIMModelManagerDelegate> delegate;

-(instancetype)initWithdataSource:(NSDictionary *)info;

-(MissIMFrame *)getRandomItemsToDataSource:(NSInteger)number;

//把数据添加到管理对象
-(void)addMissIMDataSource:(NSDictionary *)dict ordered:(BOOL)Ordered;

//写入缓存文件
-(BOOL)writeToMissIMPlistFile:(NSString *)messageId conversationId:(NSString *)conversationId timeId:(int64_t)timestamp messageNumber:(NSInteger)messageNumber;

//创建一个图片的文件路径
-(NSString *)createImageFilePath;


//解析历史消息
-(void)parseHistoryMessage:(NSArray *)historyMessageArray ordered:(BOOL) Ordered;

@end
