//
//  ScoreOverallVC.m
//  TelematicsApp
//
//  Created by DATA MOTION PTE. LTD. on 09.04.20.
//  Copyright © 2019-2021 DATA MOTION PTE. LTD. All rights reserved.
//

#import "ScoreOverallVC.h"
#import "GlobalLeadCell.h"
#import "PagesCell.h"
#import "LeaderboardResultResponse.h"
#import "LeaderboardResponse.h"
#import "UIImageView+WebCache.h"

@interface ScoreOverallVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView        *tableView;
@property (weak, nonatomic) IBOutlet UILabel            *scoreTitle;
@property (weak, nonatomic) IBOutlet UIView             *backViewTitle;
@property (weak, nonatomic) IBOutlet UIView             *placeholderView;
@property (weak, nonatomic) IBOutlet UIImageView        *placeholderImg;
@property (strong, nonatomic) TelematicsLeaderboardModel       *leaderboardModel;
@property (strong, nonatomic) LeaderboardResponse       *leaderboard;

@end

@implementation ScoreOverallVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.leaderboardModel = [TelematicsLeaderboardModel MR_findFirstByAttribute:@"leaderboard_user" withValue:@1];
    self.scoreTitle.text = localizeString(@"Overall Safety Score");
    
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    [self.tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [self.tableView setSeparatorColor:[UIColor clearColor]];
    
    self.placeholderView.hidden = YES;
    
    self.view.layer.cornerRadius = 16;
    self.view.layer.masksToBounds = NO;
    self.view.layer.shadowOffset = CGSizeMake(0, 0);
    self.view.layer.shadowRadius = 2;
    self.view.layer.shadowOpacity = 0.1;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.leaderboardModel.leaderboardRate.count == 0) {
        [[MainApiRequest requestWithCompletion:^(id response, NSError *error) {
            if (!error && [response isSuccesful]) {
                self.leaderboard = response;
                self.leaderboardModel.leaderboardRate = self.leaderboard.Result.Users;
                [self.tableView reloadData];
                
                if (self.leaderboard.Result.Users.count == 0)
                    self.placeholderView.hidden = NO;
                else
                    self.placeholderView.hidden = YES;
            }
        }] getLeaderboardScore:6];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    LeaderboardResultResponse *userProperties = self.leaderboardModel.leaderboardGlobal[0];
    if (userProperties != nil) {
        if (userProperties.Place.intValue <= 10 && userProperties.UsersNumber.intValue <= 10) {
            return userProperties.UsersNumber.intValue;
        } else if (userProperties.Place.intValue <= 10 && userProperties.UsersNumber.intValue > 10) {
            return 10;
        } else if (userProperties.Place.intValue <= 11) {
            return 11;
        } else if (userProperties.Place.intValue <= 12) {
            return 12;
        } else if (userProperties.Place.intValue <= 13) {
            return 13;
        } else {
            return self.leaderboardModel.leaderboardRate.count;
        }
    } else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 46;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GlobalLeadCell *cellGlobal = [tableView dequeueReusableCellWithIdentifier:@"GlobalLeadCell"];
    
    LeaderboardResultResponse *userProperties = self.leaderboardModel.leaderboardGlobal[0];
    if (self.leaderboardModel.leaderboardRate.count == 0) {
        cellGlobal.positionLbl.text = [NSString stringWithFormat:@"%.0ld", indexPath.row+1];
        cellGlobal.useravatar.layer.cornerRadius = cellGlobal.useravatar.layer.frame.size.width/2;
        cellGlobal.useravatar.layer.masksToBounds = YES;
        cellGlobal.useravatar.layer.borderWidth = 0.3;
        cellGlobal.useravatar.layer.borderColor = [Color officialMainAppColor].CGColor;
        cellGlobal.useravatar.contentMode = UIViewContentModeScaleAspectFill;
        cellGlobal.scoreLbl.text = @"100";
        return cellGlobal;
    }
    
    LeaderboardObject *objGlobal = self.leaderboardModel.leaderboardRate[indexPath.row];
    if (!cellGlobal) {
        cellGlobal = [[GlobalLeadCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"GlobalLeadCell"];
    }
    cellGlobal.positionLbl.text = [NSString stringWithFormat:@"%.0f", objGlobal.Place.floatValue];
    
    UIView *separatorLineView = [[UIView alloc] initWithFrame:CGRectMake(0, cellGlobal.frame.size.height-1, self.view.frame.size.width, 1)];
    separatorLineView.backgroundColor = [Color separatorLightGrayColor];
    [cellGlobal.contentView addSubview:separatorLineView];
    
    NSString *firstName = objGlobal.FirstName ? objGlobal.FirstName : @"";
    NSString *lastName = objGlobal.LastName ? objGlobal.LastName : @"";
    if ([firstName isEqualToString:@""] && [lastName isEqualToString:@""]) {
        firstName = objGlobal.Nickname;
        lastName = @"";
    }
    
    cellGlobal.usernameLbl.text = [NSString stringWithFormat:@"%@ %@", firstName, lastName];
    cellGlobal.scoreLbl.text = [NSString stringWithFormat:@"%.1f", objGlobal.Value.floatValue];
    
    cellGlobal.useravatar.layer.cornerRadius = cellGlobal.useravatar.layer.frame.size.width/2;
    cellGlobal.useravatar.layer.masksToBounds = YES;
    cellGlobal.useravatar.layer.borderWidth = 0.3;
    cellGlobal.useravatar.layer.borderColor = [Color officialMainAppColor].CGColor;
    cellGlobal.useravatar.contentMode = UIViewContentModeScaleAspectFill;
    [cellGlobal.useravatar sd_setImageWithURL:[NSURL URLWithString:objGlobal.Image]
                             placeholderImage:[UIImage imageNamed:@"no_avatar"]];
    
    UIView *bg = [[UIView alloc] init];
    
    if (objGlobal.IsCurrentUser.intValue == 1) {
        tableView.allowsMultipleSelection = YES;
        cellGlobal.selectionStyle = UITableViewCellSelectionStyleBlue;
        cellGlobal.backgroundView = [[UIImageView alloc] initWithImage:[[UIImage imageNamed:@"green_blur"] stretchableImageWithLeftCapWidth:21 topCapHeight:15]];
        [cellGlobal setSelectedBackgroundView:bg];
        [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        self.tableView.allowsSelection = NO;
    } else {
        cellGlobal.backgroundView = [[UIImageView alloc] initWithImage:nil];
        [cellGlobal setSelectedBackgroundView:bg];
        
        if (userProperties.Place.intValue >= 11) {
            if ((indexPath.row == 10 || indexPath.row == self.leaderboardModel.leaderboardRate.count-1) && userProperties.Place.intValue != 11 && userProperties.Place.intValue != 12 && userProperties.Place.intValue != 13 && userProperties.Place.intValue != 14 && userProperties.Place.intValue != 15) {
                PagesCell *cellPages = [tableView dequeueReusableCellWithIdentifier:@"PagesCell"];
                if (!cellPages) {
                    cellPages = [[PagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PagesCell"];
                }
                return cellPages;
            }
            
            if (indexPath.row == 10) {
                PagesCell *cellPages = [tableView dequeueReusableCellWithIdentifier:@"PagesCell"];
                if (!cellPages) {
                    cellPages = [[PagesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PagesCell"];
                }
                return cellPages;
            }
        }
    }
    
    return cellGlobal;
}

- (IBAction)backPageAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"leadersPrevPage" object:nil];
}

- (IBAction)nextPageAction:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"leadersNextPage" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
