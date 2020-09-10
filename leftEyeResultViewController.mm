//
//  PickerViewController.m
//  EyeTracker
//
//  Created by Weiwen Xu on 15/02/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#import "leftEyeResultViewController.h"


@interface leftEyeResultViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *showImage;
@property (strong, nonatomic) IBOutlet UIImageView *showImageSized;
@property (strong, nonatomic) IBOutlet UIImageView *frontalImage;
@property (strong, nonatomic) IBOutlet UIImageView *frontalImageSized;


@property (strong, nonatomic) IBOutlet UILabel *XDeviation;
@property (strong, nonatomic) IBOutlet UILabel *YDeviation;
@property (strong, nonatomic) IBOutlet UILabel *frontalEyeX;
@property (strong, nonatomic) IBOutlet UILabel *frontalEyeY;
@property (strong, nonatomic) IBOutlet UILabel *otherEyeX;
@property (strong, nonatomic) IBOutlet UILabel *otherEyeY;
@property (strong, nonatomic) IBOutlet UILabel *warningMessage;


@end

@implementation leftEyeResultViewController

- (void)viewDidLoad{
    [super viewDidLoad];

    _menuContent = [[NSArray alloc]initWithObjects:@"To Left", @"To right", @"Up", @"Down", nil];
    _dropDownMenu.delegate = self;
    _dropDownMenu.dataSource = self;
    _dropDownMenu.hidden = YES;
    
    [self initialiseView];
    
}

/**
 * Initialise the view with frontal eye image.
 * If no frontal eye image is imported, print the error message.
 **/
-(void)initialiseView{
    // Check whether frontal image is imported
    if([_listToShow getResultAtIndex:0].resultImage){
        // YES,
        // Show the image
        _frontalImageSized.image = [_listToShow getResultAtIndex:0].resultImage;
        [_frontalImage setImage:[_listToShow getResultAtIndex:0].resultImage];
        _frontalImage.frame = CGRectMake(_frontalImage.frame.origin.x, _frontalImage.frame.origin.y, [_listToShow getResultAtIndex:0].resultImage.size.width, [_listToShow getResultAtIndex:0].resultImage.size.height);
        
        // Print the location
        self.frontalEyeX.text = [NSString stringWithFormat:@"X    %ld",(long)[_listToShow getResultAtIndex:0].xCordinate];
        self.frontalEyeY.text = [NSString stringWithFormat:@"Y    %ld",(long)[_listToShow getResultAtIndex:0].yCordinate];
        self.warningMessage.text = NULL;
        self.otherEyeX.text = NULL;
        self.otherEyeY.text = NULL;
        self.XDeviation.text = NULL;
        self.YDeviation.text = NULL;
    }else{
        // NO,
        // Print error message
        self.warningMessage.text = [NSString stringWithFormat: @"Please Take Frontal Image!"];
        self.warningMessage.textAlignment = NSTextAlignmentCenter;
        self.frontalEyeX.text = NULL;
        self.frontalEyeY.text = NULL;
        self.otherEyeX.text = NULL;
        self.otherEyeY.text = NULL;
        self.XDeviation.text = NULL;
        self.YDeviation.text = NULL;
    }
    

}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_menuContent count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *menuIndentifier = @"simpleMenu";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:menuIndentifier];

    if(cell == nil){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:menuIndentifier];
    }

    cell.textLabel.text = [_menuContent objectAtIndex:indexPath.row];

    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [_dropDownMenu cellForRowAtIndexPath:indexPath];

    [_titleOutlet setTitle: cell.textLabel.text forState:UIControlStateNormal];
    
    if(self.warningMessage.text==NULL){
        [self tableAction];
    }

    _dropDownMenu.hidden = YES;
}

/**
 * Update view according to selected direction
 **/
-(void)tableAction{
    if ([_titleOutlet.currentTitle isEqualToString:@"To Left"]){
        [self updateResultDataWithID:1];
        
    }else if ([_titleOutlet.currentTitle isEqualToString:@"To right"]){
        [self updateResultDataWithID:2];
        
    }else if ([_titleOutlet.currentTitle isEqualToString:@"Up"]){
        [self updateResultDataWithID:3];
        
    }else if ([_titleOutlet.currentTitle isEqualToString:@"Down"]){
        [self updateResultDataWithID:4];
        
    }
}

/**
 * Update view according to index
 **/
-(void)updateResultDataWithID:(NSInteger)index{
    // Check whether data in that direction is imported
    try {
        // YES,
        // Show image
        _showImageSized.image = [_listToShow getResultAtIndex:index].resultImage;
        [_showImage setImage:[_listToShow getResultAtIndex:index].resultImage];
        _showImage.frame = CGRectMake(_showImage.frame.origin.x, _showImage.frame.origin.y, [_listToShow getResultAtIndex:index].resultImage.size.width, [_listToShow getResultAtIndex:index].resultImage.size.height);
        
        // Print pupil location
        self.otherEyeX.text = [NSString stringWithFormat:@"X    %ld",(long)[_listToShow getResultAtIndex:index].xCordinate];
        self.otherEyeY.text = [NSString stringWithFormat:@"Y    %ld",(long)[_listToShow getResultAtIndex:index].yCordinate];
        
        // Calculate deviation and print them out
        self.XDeviation.text = [NSString stringWithFormat: @"X Deviation    %ld", (long)[_listToShow deviation:0 andWith:index inCordination:@"X"]];
        self.YDeviation.text = [NSString stringWithFormat: @"Y Deviation    %ld", (long)[_listToShow deviation:0 andWith:index inCordination:@"Y"]];

    } catch (NSException *e) {
        // NO,
        // Print error message
        self.showImage.image = nil;
        self.showImageSized.image = nil;
        self.XDeviation.text = nil;
        self.YDeviation.text = nil;
        self.otherEyeX.text = [NSString stringWithFormat: @"Image Not Imported!"];
        self.otherEyeY.text = nil;
    }
    
}


- (IBAction)titleButtonTapped:(id)sender {
    if(_dropDownMenu.hidden == YES){
        _dropDownMenu.hidden = NO;
    }else{
        _dropDownMenu.hidden = YES;
    }
}


@end
