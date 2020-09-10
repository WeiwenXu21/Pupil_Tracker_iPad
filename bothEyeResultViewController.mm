//
//  bothEyeResultViewController.m
//  EyeTracker
//
//  Created by Weiwen Xu on 24/04/2017.
//  Copyright © 2017 Weiwen Xu. All rights reserved.
//

#import "bothEyeResultViewController.h"

@interface bothEyeResultViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *leftEyeFrontalImg;
@property (strong, nonatomic) IBOutlet UIImageView *leftEyeOtherImg;
@property (strong, nonatomic) IBOutlet UILabel *leftEyeXDeviation;
@property (strong, nonatomic) IBOutlet UILabel *leftEyeYDeviation;

@property (strong, nonatomic) IBOutlet UIImageView *rightEyeFrontalImg;
@property (strong, nonatomic) IBOutlet UIImageView *rightEyeOtherImg;
@property (strong, nonatomic) IBOutlet UILabel *rightEyeXDeviation;
@property (strong, nonatomic) IBOutlet UILabel *rightEyeYDeviation;

@property (strong, nonatomic) IBOutlet UILabel *leftWarningMessage;
@property (strong, nonatomic) IBOutlet UILabel *rightWarningMessage;

@end


@implementation bothEyeResultViewController

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
    // Check left eye whether frontal image is imported
    if([_leftEyelistToShow getResultAtIndex:0].resultImage){
        // YES,
        // Show the image
        self.leftEyeFrontalImg.image = [_leftEyelistToShow getResultAtIndex:0].resultImage;
        self.leftWarningMessage.text = NULL;
        
    }else{
        // NO,
        // Print error message
        self.leftWarningMessage.text = [NSString stringWithFormat: @"Please Take Frontal Image!"];
        self.leftWarningMessage.textAlignment = NSTextAlignmentCenter;
    }
    self.leftEyeXDeviation.text = nil;
    self.leftEyeYDeviation.text = nil;
    
    // Check right eye whether frontal image is imported
    if([_rightEyelistToShow getResultAtIndex:0].resultImage){
        // YES,
        // Show the image
        self.rightEyeFrontalImg.image =[_rightEyelistToShow getResultAtIndex:0].resultImage;
        self.rightWarningMessage.text = NULL;
        
    }else{
        // NO,
        // Print error message
        self.rightWarningMessage.text = [NSString stringWithFormat: @"Please Take Frontal Image!"];
        self.rightWarningMessage.textAlignment = NSTextAlignmentCenter;
    }
    
    self.rightEyeXDeviation.text = nil;
    self.rightEyeYDeviation.text = nil;
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

    
    if(self.leftWarningMessage.text==NULL&&self.rightWarningMessage.text==NULL){
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
        
    }else if ([_titleOutlet.currentTitle isEqualToString:@"Horizontal"]){
        
    }else if ([_titleOutlet.currentTitle isEqualToString:@"Vertical"]){
        
    }
}

/**
 * Update view according to index
 **/
-(void)updateResultDataWithID:(NSInteger)index{
    // Check whether data in that direction is imported
    try{
        // YES,
        // Show left eye image
        self.leftEyeOtherImg.image = [_leftEyelistToShow getResultAtIndex:index].resultImage;
        
        // Calculate deviation and print them out
        self.leftEyeXDeviation.text = [NSString stringWithFormat: @"Left Eye X Deviation    %ld", (long)[_leftEyelistToShow deviation:0 andWith:index inCordination:@"X"]];
        self.leftEyeYDeviation.text = [NSString stringWithFormat: @"Left Eye Y Deviation    %ld", (long)[_leftEyelistToShow deviation:0 andWith:index inCordination:@"Y"]];
        
        // YES,
        // Show right eye image
        self.rightEyeOtherImg.image = [_rightEyelistToShow getResultAtIndex:index].resultImage;
        
        // Calculate deviation and print them out
        self.rightEyeXDeviation.text = [NSString stringWithFormat: @"Right Eye X Deviation    %ld", (long)[_rightEyelistToShow deviation:0 andWith:index inCordination:@"X"]];
        self.rightEyeYDeviation.text = [NSString stringWithFormat: @"Right Eye Y Deviation    %ld", (long)[_rightEyelistToShow deviation:0 andWith:index inCordination:@"Y"]];
        
    }catch(NSException *e){
        // NO,
        // Print error message
        self.leftEyeOtherImg.image = nil;
        self.leftEyeXDeviation.text = [NSString stringWithFormat: @"Image Not Imported!"];
        self.leftEyeYDeviation.text = nil;
        
        self.rightEyeOtherImg.image = nil;
        self.rightEyeXDeviation.text = [NSString stringWithFormat: @"Image Not Imported!"];
        self.rightEyeYDeviation.text = nil;
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
