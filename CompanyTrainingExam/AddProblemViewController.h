//
//  AddProblemViewController.h
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AddProblemViewController : NSViewController
@property (nonatomic, strong) IBOutlet NSTextField * textField;
@property (nonatomic, strong) IBOutlet NSTextField * answerField;
@property (nonatomic, strong) IBOutlet NSPopUpButton * tagField;
- (IBAction)buttonClicked:(id)sender;
- (IBAction)cancelClicked:(id)sender;
//- (IBAction)dismissController:(id)sender;s
@end
