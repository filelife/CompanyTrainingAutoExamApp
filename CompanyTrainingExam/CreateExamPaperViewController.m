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
@property (nonatomic, strong) NSArray * problemArray;
@end

@implementation CreateExamPaperViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    AppDelegate * appdelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    _context = appdelegate.managedObjectContext;
    [self allProblem];
    // Do view setup here.
}
- (void)allProblem {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProblemEntity"];
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    self.problemArray = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    
}

- (IBAction)createExamPaper:(id)sender {
    [self allProblem];
    [self formPaper];
    [self createPaper];
}

- (void)formPaper {
    self.examContext = [NSString stringWithFormat:@"考卷:\n"];
    NSInteger index = 1;
    for(ProblemEntity * entity in self.problemArray) {
        NSString * problem = [NSString stringWithFormat:@"%@\n",entity.problem];
        self.examContext = [self.examContext stringByAppendingString:problem];
    }
    NSString * answer = [NSString stringWithFormat:@"答案:\n"];
    index = 1;
    for(ProblemEntity * entity in self.problemArray) {
        NSString * answerTemp =[NSString stringWithFormat:@"%ld.%@\t",index,entity.answer];
        answer = [answer stringByAppendingString:answerTemp];
        index++;
        
    }
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

@end
