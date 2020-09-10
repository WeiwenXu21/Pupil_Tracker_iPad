//
//  rightEyeResultViewController.h
//  EyeTracker
//
//  Created by Weiwen Xu on 09/04/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//
/* rightEyeResultViewController_h */

#import <UIKit/UIKit.h>
#import "ResultList.h"

@interface rightEyeResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UIButton *titleOutlet;
@property (weak, nonatomic) IBOutlet UITableView *dropDownMenu;
@property (strong, nonatomic) NSArray *menuContent;

@property (strong, nonatomic) ResultList *listToShow;

@end
