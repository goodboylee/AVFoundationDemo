//
//  MainTableViewController.m
//  AVFoundationDemo
//
//  Created by lotus on 2018/1/23.
//  Copyright © 2018年 lotus. All rights reserved.
//

#import "MainTableViewController.h"
#import "StillAndVideoViewController.h"

static NSString *cellID = @"cellID";

@interface MainTableViewController ()

@property (nonatomic, strong) NSArray *datas;
@end

@implementation MainTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
}

- (void)initData{
    _datas = @[@"still and video media capture"];
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    cell.textLabel.text = _datas[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        StillAndVideoViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StillAndVideoViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end














