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
#define HEX_RGBA(s,a) [NSColor colorWithRed:(((s & 0xFF0000) >> 16))/255.0 green:(((s &0xFF00) >>8))/255.0 blue:((s & 0xFF))/255.0 alpha:a]
#define BackgroundColor HEX_RGBA(0xffb3a7,0.1)
#define SelectColor HEX_RGBA(0xffc20e,0.8)
@interface ViewController() <NSTextFieldDelegate, NSTableViewDataSource, NSTableViewDelegate>
@property (nonatomic, strong) NSString * textFieldValue;
@property (nonatomic, strong) NSManagedObjectContext * context;
@property (nonatomic, strong) NSArray * problemArray;
@property (nonatomic, strong) NSMutableArray * searchResArray;
@property (nonatomic, strong) ProblemEntity * currentSelectProblem;
@property (nonatomic, assign) BOOL isInSearch;
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
    self.problemTableView.selectionHighlightStyle = NSTableViewSelectionHighlightStyleNone;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(freshDataClicked:)
                                                 name:@"FreshData"
                                               object:nil];
    _isInSearch = NO;
    self.searchResArray = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[BackgroundColor CGColor]];
    
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self allProblem];
    if(self.problemTableView) {
        [self.problemTableView reloadData];
    }
    
}

- (IBAction)searchAnswer:(id)sender {
    NSSearchField * searchField = (NSSearchField *)sender;
    NSLog(@"search answer: %@", [searchField stringValue]);
    if([searchField stringValue].length == 0) {
        self.isInSearch = NO;
        [self.problemTableView reloadData];
    } else {
        self.isInSearch = YES;
        [self searchProblemWithString:[searchField stringValue]];
        [self.problemTableView reloadData];
    }
    
}

- (void)searchProblemWithString:(NSString *)string {
    self.searchResArray = nil;
    self.searchResArray = [NSMutableArray array];
    for(ProblemEntity * entity in self.problemArray) {
        if(string) {
            if([entity.problem rangeOfString:string].location != NSNotFound) {
                [self.searchResArray addObject:entity];
            } else if([entity.answer rangeOfString:string].location != NSNotFound) {
                [self.searchResArray addObject:entity];
            } else if([entity.type rangeOfString:string].location != NSNotFound) {
                [self.searchResArray addObject:entity];
            } else if(entity.problemid.integerValue == [string integerValue]) {
                [self.searchResArray addObject:entity];
            }
        }
    }
}

- (void)count {
    NSInteger choiceCount = 0,fillInBlanksCount = 0, judgeCount = 0;
    
    for(ProblemEntity * entity in self.problemArray) {
        if([entity.type isEqualToString:@"选择题"]) {
            choiceCount++;
        } else if([entity.type isEqualToString:@"填空题"]) {
            fillInBlanksCount++;
        } else if([entity.type isEqualToString:@"判断题"]) {
            judgeCount++;
        }
    }
    self.choiceCountLab.stringValue = [NSString stringWithFormat:@"%ld 道",choiceCount];
    self.fillInblanksCountLab.stringValue = [NSString stringWithFormat:@"%ld 道",fillInBlanksCount];
    self.judgeCountLab.stringValue = [NSString stringWithFormat:@"%ld 道",judgeCount];
}

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    if(_isInSearch == NO) {
        return self.problemArray.count;
    } else {
        return self.searchResArray.count;
    }
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    //do something
    return 32.f;
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    if(_isInSearch == NO) {
        self.currentSelectProblem = [self.problemArray objectAtIndex:row];
    } else {
        self.currentSelectProblem = [self.searchResArray objectAtIndex:row];
    }
    
    for(int i = 0; i < self.problemArray.count;i++) {
        NSTableRowView * tableRow = [self.problemTableView rowViewAtRow:i makeIfNecessary:YES];
        if(i == row) {
            tableRow.layer.masksToBounds = YES;
            tableRow.layer.borderWidth = 3;
            tableRow.layer.borderColor = SelectColor.CGColor;
        } else {
            tableRow.layer.masksToBounds = YES;
            tableRow.layer.borderWidth = 0;
            
        }
    }
    return YES;
}

- (nullable NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row {
    NSTextField *view   = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 1, 100, 28)];
    view.bordered       = NO;
    view.editable       = NO;
    view.backgroundColor = [NSColor clearColor];
    ProblemEntity *p ;
    if(!_isInSearch) {
        p = [self.problemArray objectAtIndex:row];
    } else {
        p = [self.searchResArray objectAtIndex:row];
    }
    
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
    
    NSTableRowView * tableRow = [tableView rowViewAtRow:row makeIfNecessary:YES];
    
    NSInteger res = row % 2;
    NSLog(@"row:%ld res:%ld\n",row ,res);
    if(res == 1) {
        tableRow.backgroundColor = BackgroundColor;
    } else {
        tableRow.backgroundColor = [NSColor clearColor];
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
    if(self.currentSelectProblem) {
        [self showDeleteAlert];
    } else {
        [self noSelectProblem];
    }
    
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
        for (ProblemEntity *obj in datas) {
            if(obj.problemid == self.currentSelectProblem.problemid) {
                [_context deleteObject:obj];
            }
        }
        if (![_context save:&error])
        {
            NSLog(@"error:%@",error);
        }
    }
//    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ProblemInfo" ofType:@"plist"];
//    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
//    [data setValue:@(0) forKey:@"lastMaxId"];
//    [data writeToFile:plistPath atomically:YES];
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
    [self count];
}

- (void)noSelectProblem {
    NSAlert *alert = [[NSAlert alloc]init];
    //添加两个按钮吧
    [alert addButtonWithTitle:@"确定"];
    
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    //正文
    alert.messageText = @"删除";
    //描述文字
    alert.informativeText = @"还未选定要删除的题目。";
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
    
}

- (void)showDeleteAlert {
    NSAlert *alert = [[NSAlert alloc]init];
    //添加两个按钮吧
    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    //正文
    alert.messageText = @"删除";
    //描述文字
    alert.informativeText = @"确定删除所选题目？";
    //弹窗类型 默认类型 NSAlertStyleWarning
    [alert setAlertStyle:NSAlertStyleWarning];
    //回调Block
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            [self deleteAllData];
            [self allProblem];
            [self.problemTableView reloadData];
            self.currentSelectProblem = nil;
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}

@end
