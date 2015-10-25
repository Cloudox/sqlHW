//
//  HighDataVC.m
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import "HighDataVC.h"
#import "HighOperateVC.h"

@interface HighDataVC ()

@end

@implementation HighDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"High";
    
    // 导航栏右侧设置按钮
    UIBarButtonItem *operateButton = [[UIBarButtonItem alloc] initWithTitle:@"操作" style:UIBarButtonItemStyleBordered target:self action:@selector(operate)];
    self.navigationItem.rightBarButtonItem = operateButton;
    
    if (!self.highDB) {//判断数据库是否存在，不存在则创建数据库
        //获取文件路径
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbFilePath = [docs[0] stringByAppendingPathComponent:@"highDB.sqlite"];
        //获取或创建数据库
        self.highDB = [FMDatabase databaseWithPath:dbFilePath];
    }
    if (![self.highDB open]) {//判断数据库是否打开，没打开则提示失败
        NSLog(@"打开数据库失败");
        return;
    }
    [self.highDB setShouldCacheStatements:YES];//为数据库设置缓存，提高查询效率
    
    if (!self.lowDB) {//判断数据库是否存在，不存在则创建数据库
        //获取文件路径
        NSArray *docs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *dbFilePath = [docs[0] stringByAppendingPathComponent:@"lowDB.sqlite"];
        //获取或创建数据库
        self.lowDB = [FMDatabase databaseWithPath:dbFilePath];
    }
    if (![self.lowDB open]) {//判断数据库是否打开，没打开则提示失败
        NSLog(@"打开数据库失败");
        return;
    }
    [self.lowDB setShouldCacheStatements:YES];//为数据库设置缓存，提高查询效率
    


}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 清除所有label
    for (UIView *view in [self.view subviews])
    {
        if ([view isKindOfClass:[UILabel class]])
        {
            [view removeFromSuperview];
        }
    }
    
    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 110, 70, 30)];
    idLabel.text = @"AgentId";
    idLabel.font = [UIFont systemFontOfSize:17];
    idLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:idLabel];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 110, 70, 30)];
    nameLabel.text = @"Name";
    nameLabel.font = [UIFont systemFontOfSize:17];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:nameLabel];
    
    UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 110, 70, 30)];
    missionLabel.text = @"Mission";
    missionLabel.font = [UIFont systemFontOfSize:17];
    missionLabel.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:missionLabel];
    
    int i = 0;
    
    // 高级数据库
    if ([self.highDB tableExists:@"agent"]) {
        FMResultSet *rs = [self.highDB executeQuery:@"SELECT * FROM agent"];
        //循环读取所有搜索到的数据获取想要的列信息，这里只有一行，获取对应的密码
        while ([rs next]) {
            UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 150 + i*40, 40, 30)];
            idLabel.text = [rs stringForColumn:@"Agentid"];
            idLabel.text = [rs stringForColumn:@"Agentid"];
            idLabel.font = [UIFont systemFontOfSize:17];
            idLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:idLabel];
            
            UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 150 + i*40, 70, 30)];
            if (![[rs stringForColumn:@"Name"] isEqualToString:@""]) {// 存在数据
                nameLabel.text = [rs stringForColumn:@"Name"];
            } else {// 无数据，向低级数据库查询补全
                FMResultSet *rslow = [self.lowDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", [rs stringForColumn:@"Agentid"]];
                while ([rslow next]) {
                    nameLabel.text = [rslow stringForColumn:@"Name"];
                }
            }
            nameLabel.font = [UIFont systemFontOfSize:17];
            nameLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:nameLabel];
            
            UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 150 + i*40, 70, 30)];
            if (![[rs stringForColumn:@"Mission"] isEqualToString:@""]) {// 存在数据
                missionLabel.text = [rs stringForColumn:@"Mission"];
            } else {// 无数据，向低级数据库查询补全
                FMResultSet *rslow = [self.lowDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", [rs stringForColumn:@"Agentid"]];
                while ([rslow next]) {
                    missionLabel.text = [rslow stringForColumn:@"Mission"];
                }
            }
            missionLabel.font = [UIFont systemFontOfSize:17];
            missionLabel.textAlignment = NSTextAlignmentCenter;
            [self.view addSubview:missionLabel];
            
            i++;
        }
    }
    
    
    // 低级数据库
    if ([self.lowDB tableExists:@"agent"]) {
        FMResultSet *rs = [self.lowDB executeQuery:@"SELECT * FROM agent"];
        //循环读取所有搜索到的数据获取想要的列信息，这里只有一行，获取对应的密码
        while ([rs next]) {
            // 检查是否删除过
            FMResultSet *rsdelete = [self.highDB executeQuery:@"SELECT * FROM deletelow WHERE Agentid = (?)", [rs stringForColumn:@"Agentid"]];
            if (![rsdelete next]) {// 没删除过，才显示
                // 检查高级数据库是否已经有重复数据
                FMResultSet *rshigh = [self.highDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", [rs stringForColumn:@"Agentid"]];
                if ([rshigh next]) {// 高级数据库有相应id
     
                    
                    
                    
                    /*
                     NSLog(@"yes");
                     rshigh = [self.highDB executeQuery:@"SELECT * FROM agent WHERE Agentid = (?)", [rs stringForColumn:@"Agentid"]];
                     while ([rshigh next]) {
                     UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 150 + i*40, 40, 30)];
                     idLabel.text = [rs stringForColumn:@"Agentid"];
                     idLabel.font = [UIFont systemFontOfSize:17];
                     idLabel.textAlignment = NSTextAlignmentCenter;
                     [self.view addSubview:idLabel];
                     
                     if ([[rshigh stringForColumn:@"Name"] isEqualToString:@""]) {// 如果姓名栏为空,拉去低级数据来补全
                     UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 150 + i*40, 70, 30)];
                     nameLabel.text = [rs stringForColumn:@"Name"];
                     nameLabel.font = [UIFont systemFontOfSize:17];
                     nameLabel.textAlignment = NSTextAlignmentCenter;
                     [self.view addSubview:nameLabel];
                     } else {// 不为空，直接用高级数据
                     UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 150 + i*40, 70, 30)];
                     nameLabel.text = [rshigh stringForColumn:@"Name"];
                     nameLabel.font = [UIFont systemFontOfSize:17];
                     nameLabel.textAlignment = NSTextAlignmentCenter;
                     [self.view addSubview:nameLabel];
                     }
                     
                     if ([[rshigh stringForColumn:@"Mission"] isEqualToString:@""]) {// 如果任务栏为空，拉去低级数据来补全
                     UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 150 + i*40, 70, 30)];
                     missionLabel.text = [rs stringForColumn:@"Mission"];
                     missionLabel.font = [UIFont systemFontOfSize:17];
                     missionLabel.textAlignment = NSTextAlignmentCenter;
                     [self.view addSubview:missionLabel];
                     } else {// 不为空，直接用高级数据
                     UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 150 + i*40, 70, 30)];
                     missionLabel.text = [rshigh stringForColumn:@"Mission"];
                     missionLabel.font = [UIFont systemFontOfSize:17];
                     missionLabel.textAlignment = NSTextAlignmentCenter;
                     [self.view addSubview:missionLabel];
                     }
                     }
                     */
    
    
                } else {// 高级数据库无相应id
                    UILabel *idLabel = [[UILabel alloc] initWithFrame:CGRectMake(55, 150 + i*40, 40, 30)];
                    idLabel.text = [rs stringForColumn:@"Agentid"];
                    idLabel.font = [UIFont systemFontOfSize:17];
                    idLabel.textAlignment = NSTextAlignmentCenter;
                    [self.view addSubview:idLabel];
                    
                    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(142, 150 + i*40, 70, 30)];
                    nameLabel.text = [rs stringForColumn:@"Name"];
                    nameLabel.font = [UIFont systemFontOfSize:17];
                    nameLabel.textAlignment = NSTextAlignmentCenter;
                    [self.view addSubview:nameLabel];
                    
                    UILabel *missionLabel = [[UILabel alloc] initWithFrame:CGRectMake(245, 150 + i*40, 70, 30)];
                    missionLabel.text = [rs stringForColumn:@"Mission"];
                    missionLabel.font = [UIFont systemFontOfSize:17];
                    missionLabel.textAlignment = NSTextAlignmentCenter;
                    [self.view addSubview:missionLabel];
                    
                    i++; 
                }
     
            }
            
        }
    }
     
}

// 操作
- (void)operate {
    HighOperateVC *highOperateVC = [[HighOperateVC alloc] initWithNibName:@"HighOperateVC" bundle:nil];
    [self.navigationController pushViewController:highOperateVC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
