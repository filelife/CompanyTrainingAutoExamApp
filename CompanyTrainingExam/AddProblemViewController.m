//
//  AddProblemViewController.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "AddProblemViewController.h"
#import <CoreData/CoreData.h>
#import "ProblemEntity+CoreDataClass.h"
#import "AppDelegate.h"
@interface AddProblemViewController ()
@property (nonatomic, strong) NSManagedObjectContext * context;
@end

@implementation AddProblemViewController
- (void)loadView {
    [super loadView];
    AppDelegate * appdelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    _context = appdelegate.managedObjectContext;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
}

- (void)viewWillDisappear {
    _context = nil;
}
- (IBAction)buttonClicked:(id)sender {
    [self addProblem];
}

- (IBAction)cancelClicked:(id)sender {
    
    [self removeFromParentViewController];
}


/**
 新增个人记录
 */
- (void)addProblem {
    if(self.textField.stringValue.length == 0 ||
       self.answerField.stringValue.length == 0) {
        [self warningAlert];
        return;
    }
    /**
     回顾SQL新增记录的过程
     
     1. 拼接一个INSERT的SQL语句
     2. 执行SQL
     */
    // 1. 实例化并让context“准备”将一条个人记录增加到数据库
    
    ProblemEntity *p = [NSEntityDescription insertNewObjectForEntityForName:@"ProblemEntity" inManagedObjectContext:_context];
    if(self.textField.stringValue.length) {
        p.problem = self.textField.stringValue;
    }
    if(self.answerField.stringValue.length) {
        p.answer = self.answerField.stringValue;
    }
    if(self.tagField.stringValue.length) {
        p.type = self.tagField.selectedItem.title;
    }
    p.problemid = [self getMaxID];
   
         // 3. 保存(让context保存当前的修改)
    if ([_context save:nil]) {
        NSLog(@"新增成功");
        [[NSNotificationCenter defaultCenter]
         postNotificationName:@"FreshData" object:self];
        self.textField.stringValue = @"";
        self.answerField.stringValue = @"";
        [self.textField becomeFirstResponder];
    } else {
        NSLog(@"新增失败");
    }
}

- (NSNumber *) getMaxID {
    
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ProblemInfo" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    NSNumber * mlastMaxId = [data objectForKey:@"lastMaxId"];
    NSInteger mMaxId = mlastMaxId.integerValue + 1;
    [data setValue:@(mMaxId) forKey:@"lastMaxId"];
    [data writeToFile:plistPath atomically:YES];
    return @(mMaxId);
    
}

- (void)warningAlert {
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    
    [alert addButtonWithTitle:@"确认"];
    
    
    alert.messageText = @"提示";
    
    alert.informativeText = @"未输入问题或者答案，请输入后再提交。";
    
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}

@end
