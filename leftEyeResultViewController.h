//
//  PickerViewController.h
//  EyeTracker
//
//  Created by Weiwen Xu on 15/02/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ResultList.h"
@interface leftEyeResultViewController : UIViewController<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UIButton *titleOutlet;
@property (weak, nonatomic) IBOutlet UITableView *dropDownMenu;
@property (strong, nonatomic) NSArray *menuContent;

@property (strong, nonatomic) ResultList *listToShow;

@end
