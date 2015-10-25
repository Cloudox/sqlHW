//
//  LowDataVC.m
//  sqlHM
//
//  Created by Cloudox on 15/10/19.
//  Copyright © 2015年 Cloudox. All rights reserved.
//

#import "LowDataVC.h"
#import "LowOperateVC.h"

@interface LowDataVC ()

@end

@implementation LowDataVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"Low";
    
    // 导航栏右侧设置按钮
    UIBarButtonItem *operateButton = [[UIBarButtonItem alloc] initWithTitle:@"操作" style:UIBarButtonItemStyleBordered target:self action:@selector(operate)];
    self.navigationItem.rightBarButtonItem = operateButton;
    
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
    
    if ([self.lowDB tableExists:@"agent"]) {
        FMResultSet *rs = [self.lowDB executeQuery:@"SELECT * FROM agent"];
        //循环读取所有搜索到的数据获取想要的列信息，这里只有一行，获取对应的密码
        int i = 0;
        while ([rs next]) {
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

// 操作
- (void)operate {
    LowOperateVC *lowOperateVC = [[LowOperateVC alloc] initWithNibName:@"LowOperateVC" bundle:nil];
    [self.navigationController pushViewController:lowOperateVC animated:YES];
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
