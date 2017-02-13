//
//  ViewController.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "ViewController.h"
#import "AppDelegate.h"
#import "ProblemEntity+CoreDataProperties.h"


@interface ViewController() <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSString * textFieldValue;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSArray * problemArray;
@end
@implementation ViewController

- (void)loadView {
    [super loadView];
    AppDelegate * appdelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    [appdelegate openDB];
    _context = appdelegate.managedObjectContext;
    self.problemTableView.delegate = self;
    self.problemTableView.dataSource = self;
    self.problemTableView.backgroundColor = [NSColor whiteColor ];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(freshDataClicked:)
                                                 name:@"FreshData"
                                               object:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[[NSColor whiteColor ] CGColor]];
    
    
    
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self allProblem];
    if(self.problemTableView) {
        [self.problemTableView reloadData];
    }
    
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return self.problemArray.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    //do something
    return 32.f;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    return NO;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *view   = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 1, 100, 28)];
    view.bordered       = NO;
    view.editable       = NO;
    ProblemEntity *p = [self.problemArray objectAtIndex:row];
    // 1.1.判断是哪一列
    if ([tableColumn.identifier isEqualToString:@"id"]) {
        view.stringValue    = [NSString stringWithFormat:@"%ld",p.problemid.integerValue];
    }else if ([tableColumn.identifier isEqualToString:@"type"]) {
        view.stringValue    = [NSString stringWithFormat:@"%@",p.type];
    }else if([tableColumn.identifier isEqualToString:@"answer"]){
        view.stringValue    = [NSString stringWithFormat:@"%@",p.answer];
    }else if([tableColumn.identifier isEqualToString:@"problem"] ){
        view.stringValue    = [NSString stringWithFormat:@"%@",p.problem];
    }
    return view;
}


- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)createExamPaper:(id)sender {
    
}

- (IBAction)freshDataClicked:(id)sender {
    [self allProblem];
    [self.problemTableView reloadData];
}

- (IBAction)deleteData:(id)sender {
    [self showAlert];
}

- (void)deleteAllData {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ProblemEntity" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:description];
    NSError *error = nil;
    NSArray *datas = [_context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count])
    {
        for (NSManagedObject *obj in datas)
        {
            [_context deleteObject:obj];
        }
        if (![_context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ProblemInfo" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [data setValue:@(0) forKey:@"lastMaxId"];
    [data writeToFile:plistPath atomically:YES];
}

- (void)allProblem {
    // 1. 实例化一个查询(Fetch)请求
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"ProblemEntity"];
    
    // 3. 条件查询，通过谓词来实现的
    //    request.predicate = [NSPredicate predicateWithFormat:@"age < 60 && name LIKE '*五'"];
    // 在谓词中CONTAINS类似于数据库的 LIKE '%王%'
    //    request.predicate = [NSPredicate predicateWithFormat:@"phoneNo CONTAINS '1'"];
    // 如果要通过key path查询字段，需要使用%K
    //    request.predicate = [NSPredicate predicateWithFormat:@"%K CONTAINS '1'", @"phoneNo"];
    // 直接查询字表中的条件
    // 2. 让_context执行查询数据
    AppDelegate * appDelegate = (AppDelegate *)[NSApplication sharedApplication].delegate;
    self.problemArray = [appDelegate.managedObjectContext executeFetchRequest:request error:nil];
    for (ProblemEntity *p in self.problemArray) {
        NSLog(@"Data:%ld %@ %@ %@\n",p.problemid.integerValue, p.problem, p.type, p.answer);
        
       
        
    }
    
}

- (void)showAlert {
    NSAlert *alert = [[NSAlert alloc]init];
    //可以设置产品的icon
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    //添加两个按钮吧
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    //正文
    alert.messageText = @"删除";
    //描述文字
    alert.informativeText = @"确定删除所有题目？";
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            [self deleteAllData];
            [self allProblem];
            [self.problemTableView reloadData];
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}

@end
