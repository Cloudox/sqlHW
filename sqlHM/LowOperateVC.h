//
//  LowOperateVC.h
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LowOperateVC : UIViewController
@property (strong, nonatomic) FMDatabase *lowDB;//低级数据库
@property (strong, nonatomic) FMDatabase *highDB;//高级数据库
@property (strong, nonatomic) IBOutlet UITextField *idText;
@property (strong, nonatomic) IBOutlet UITextField *nameText;
@property (strong, nonatomic) IBOutlet UITextField *missionText;

- (IBAction)addData:(id)sender;
- (IBAction)editData:(id)sender;
- (IBAction)deleteData:(id)sender;
@end
