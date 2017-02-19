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
@property (nonatomic, strong) IBOutlet NSTextField * choiceCountLab;
@property (nonatomic, strong) IBOutlet NSTextField * fillInblanksCountLab;
@property (nonatomic, strong) IBOutlet NSTextField * judgeCountLab;
@property (nonatomic, strong) IBOutlet NSSearchField * searchField;
@property (nonatomic, strong) IBOutlet NSTextField * backupSuccessField;
@property (nonatomic, strong) IBOutlet NSTextField * textField;
@property (nonatomic, strong) IBOutlet NSTextField * answerField;
@property (nonatomic, strong) IBOutlet NSPopUpButton * tagField;
@property (nonatomic, strong) IBOutlet NSButton * okButton;
@property (nonatomic, strong) IBOutlet NSButton * editButton;

- (IBAction)freshDataClicked:(id)sender;
- (IBAction)deleteData:(id)sender;
- (IBAction)searchAnswer:(id)sender;
- (IBAction)backUp:(id)sender;
- (IBAction)readBackUp:(id)sender;
- (IBAction)deleteAllData:(id)sender;
- (IBAction)searchFieldBecomeFristResponse:(id)sender;
- (IBAction)editProblem:(id)sender;
@end

