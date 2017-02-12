//
//  CreateExamPaperViewController.h
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 2017/2/12.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface CreateExamPaperViewController : NSViewController
@property (nonatomic, strong) IBOutlet NSTextField * choiceNumLab;
@property (nonatomic, strong) IBOutlet NSTextField * fillInTheBlanksNumLab;
@property (nonatomic, strong) IBOutlet NSTextField * judgmentNumLab;
@property (nonatomic, strong) IBOutlet NSTextField * choiceTextField;
@property (nonatomic, strong) IBOutlet NSTextField * fillInTheBlanksTextField;
@property (nonatomic, strong) IBOutlet NSTextField * judgmentTextField;
- (IBAction)createExamPaper:(id)sender;
@end
