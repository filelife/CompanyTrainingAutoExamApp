//
//  ViewController.h
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController
@property (nonatomic, strong) IBOutlet NSTableView * problemTableView;
@property (nonatomic, strong) IBOutlet NSButton * addProbelmButton;
@property (nonatomic, strong) IBOutlet NSButton * addExamPaperButton;
@property (nonatomic, strong) IBOutlet NSButton * deleteProblemButton;
- (IBAction)freshDataClicked:(id)sender;
- (IBAction)deleteData:(id)sender;
- (IBAction)createExamPaper:(id)sender;
@end

