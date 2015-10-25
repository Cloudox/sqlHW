//
//  LowLoginVC.h
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LowLoginVC : UIViewController
@property (strong, nonatomic) FMDatabase *highDB;//高级数据库
@property (strong, nonatomic) FMDatabase *lowDB;//低级数据库
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;


- (IBAction)login:(id)sender;
@end
