//
//  MissIMTableViewCell.h
//  missfresh
//
//  Created by xiangwenwen on 15/4/1.
//
//

#import <UIKit/UIKit.h>

@class MissIMFrame;

@protocol MissIMCellDelegate <NSObject>


@end

@interface MissIMTableViewCell : UITableViewCell

@property(nonatomic,assign) id<MissIMCellDelegate> delegate;
@property(nonatomic,retain) MissIMFrame *missIMFrame;

+(instancetype)missimWithTableViewCell:(UITableView *)tableView;

@end
