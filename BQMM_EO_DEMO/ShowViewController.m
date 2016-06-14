//
//  ShowViewController.m
//  BQMM_EO_DEMO
//
//  Created by LiChao Jun on 16/3/8.
//  Copyright © 2016年 LiChao Jun. All rights reserved.
//

#import "ShowViewController.h"
#import "define.h"
#import "EditViewController.h"
#import "ShowTableViewCell.h"
#import "MessageModel.h"

@interface ShowViewController () <UITableViewDataSource, UITableViewDelegate, EditViewDelegate>

@property(nonatomic, strong) IBOutlet UIImageView *emptyIcon;
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) NSMutableArray *dataSource;

@end

@implementation ShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.dataSource = [NSMutableArray array];
    
    self.navigationController.navigationBar.backgroundColor = RGB(0xF8, 0xF8, 0xF8);
    self.title = @"表情mm社区";
        
    self.tableView.separatorStyle = NO;
    [self.tableView registerClass:[ShowTableViewCell class] forCellReuseIdentifier:@"ShowTableViewCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)editAction:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *vc = [sb instantiateViewControllerWithIdentifier:@"EditViewNavigationController"];
    EditViewController *evc = vc.childViewControllers[0];
    evc.delegate = self;
    [self presentViewController:vc animated:YES completion:nil];
}

#pragma mark - *UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ShowTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ShowTableViewCell"];
    if (!cell) {
        cell = [[ShowTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ShowTableViewCell"];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    MessageModel *model = self.dataSource[indexPath.row];
    cell.model = model;
    
    return cell;
}

#pragma mark - *UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    MessageModel *model = self.dataSource[indexPath.row];
    return [ShowTableViewCell heightWithModel:model];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0;
}

#pragma mark - *EditViewDelegate

- (void)onSend:(MessageModel*)model {
    [self.dataSource addObject:model];
    [self.tableView reloadData];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:self.dataSource.count-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
    
    self.emptyIcon.hidden = YES;
}

@end



















