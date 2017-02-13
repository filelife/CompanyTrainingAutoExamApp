//
//  CreateExamPaperViewController.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 2017/2/12.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "CreateExamPaperViewController.h"
#import "AppDelegate.h"
#import "ProblemEntity+CoreDataProperties.h"
@interface CreateExamPaperViewController ()
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSString * examContext;
@property (nonatomic, strong) NSMutableArray * choiceArray;
@property (nonatomic, strong) NSMutableArray * fillInTheBlanksArray;
@property (nonatomic, strong) NSMutableArray * judgmentArray;
@property (nonatomic, strong) NSArray * problemArray;
@end

@implementation CreateExamPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate * appdelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    _context = appdelegate.managedObjectContext;
    [self allProblem];
    [self updateCurrentDataInfo];
    
}

- (void)updateCurrentDataInfo {
    if(self.choiceArray == nil) {
        self.choiceArray = [NSMutableArray array];
    }
    
    if(self.fillInTheBlanksArray == nil) {
        self.fillInTheBlanksArray = [NSMutableArray array];
    }
    
    if(self.judgmentArray == nil) {
        self.judgmentArray = [NSMutableArray array];
    }
    
    for(ProblemEntity * entity in self.problemArray) {
        if([entity.type isEqualToString:@"选择题"]) {
            [self.choiceArray addObject:entity];
        } else if([entity.type isEqualToString:@"判断题"]) {
            [self.judgmentArray addObject:entity];
        } else if([entity.type isEqualToString:@"填空题"]){
            [self.fillInTheBlanksArray addObject:entity];
        }
    }
    self.choiceNumLab.stringValue = [NSString stringWithFormat:@"%ld",self.choiceArray.count];
    self.judgmentNumLab.stringValue = [NSString stringWithFormat:@"%ld",self.judgmentArray.count];
    self.fillInTheBlanksNumLab.stringValue = [NSString stringWithFormat:@"%ld",self.fillInTheBlanksArray.count];
    
}

- (void)allProblem {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProblemEntity"];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    self.problemArray = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    
}

- (IBAction)createExamPaper:(id)sender {
    
    [self showAlert];
    
}

- (void)formPaper {
    self.examContext = [NSString stringWithFormat:@"考卷:\n"];
    NSString * answer = [NSString stringWithFormat:@"\n\n答案:\n"];
    NSInteger index = 1;
//    for(ProblemEntity * entity in self.problemArray) {
//        NSString * problem = [NSString stringWithFormat:@"%ld. %@\n\n",index,entity.problem];
//        self.examContext = [self.examContext stringByAppendingString:problem];
//    }
    self.examContext = [self.examContext stringByAppendingString:[NSString stringWithFormat:@"一、选择题:\n"]];
    
    answer = [answer stringByAppendingString:[NSString stringWithFormat:@"一、选择题:\n"]];
    for(ProblemEntity * entity in self.choiceArray) {
        NSString * problem = [NSString stringWithFormat:@"%ld. %@\n\n",index,entity.problem];
        self.examContext = [self.examContext stringByAppendingString:problem];
        NSString * answerTemp =[NSString stringWithFormat:@"%ld.%@\t",index,entity.answer];
        answer = [answer stringByAppendingString:answerTemp];
        index++;
    }
    
    self.examContext = [self.examContext stringByAppendingString:[NSString stringWithFormat:@"二、填空题:\n"]];
    answer = [answer stringByAppendingString:[NSString stringWithFormat:@"\n二、填空题:\n"]];
    for(ProblemEntity * entity in self.fillInTheBlanksArray) {
        NSString * problem = [NSString stringWithFormat:@"%ld. %@\n\n",index,entity.problem];
        self.examContext = [self.examContext stringByAppendingString:problem];
        NSString * answerTemp =[NSString stringWithFormat:@"%ld.%@\t",index,entity.answer];
        answer = [answer stringByAppendingString:answerTemp];
        index++;
    }
    
    self.examContext = [self.examContext stringByAppendingString:[NSString stringWithFormat:@"三、判断题:\n"]];
    answer = [answer stringByAppendingString:[NSString stringWithFormat:@"\n三、判断题:\n"]];
    for(ProblemEntity * entity in self.judgmentArray) {
        NSString * problem = [NSString stringWithFormat:@"%ld. %@\n\n",index,entity.problem];
        self.examContext = [self.examContext stringByAppendingString:problem];
        NSString * answerTemp =[NSString stringWithFormat:@"%ld.%@\t",index,entity.answer];
        answer = [answer stringByAppendingString:answerTemp];
        index++;
    }
    
    
    
    index = 1;
    
    self.examContext = [self.examContext stringByAppendingString:answer];
}

- (void)createPaper {
    NSString *fileName = @"ExamPaper.txt";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[fm currentDirectoryPath],fileName];
    
    //判断文件是否存在 不存在就结束程序
    if([fm fileExistsAtPath:path]==NO){
        NSLog(@"文件不存在");
        [fm createFileAtPath:path contents:nil attributes:nil];
        
    }
    
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingDOSChineseSimplif);
    NSData *data = [self.examContext dataUsingEncoding:enc];
    [data writeToFile: path atomically: NO];
    
    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[fm currentDirectoryPath]];
}

- (void)showAlert {
    NSAlert *alert = [[NSAlert alloc]init];
    //可以设置产品的icon
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    //添加两个按钮吧
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    //正文
    alert.messageText = @"创建试卷";
    //描述文字
    alert.informativeText = @"确定创建试卷？";
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            [self allProblem];
            [self formPaper];
            [self createPaper];
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}
@end
