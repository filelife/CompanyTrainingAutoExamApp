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
@property (nonatomic, strong) NSAlert *backUpAlert;
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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(showDeleteAllDataAlert)
                                                 name:@"DeleteData"
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(searchFieldBecomeFristResponse)
                                                 name:@"SearchData"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(writeToBackFile)
                                                 name:@"BackUpData"
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
#pragma mark action

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)searchFieldBecomeFristResponse:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SearchData" object:self];
}

- (void)searchFieldBecomeFristResponse {
    
    self.searchField.stringValue = @" ";
    [self.searchField becomeFirstResponder];
    
}

- (IBAction)deleteAllData:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DeleteData" object:self];
}



- (IBAction)freshDataClicked:(id)sender {
    self.searchField.stringValue = @"";
    self.isInSearch = NO;
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

- (IBAction)backUp:(id)sender {
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"BackUpData" object:self];
    
}


- (IBAction)readBackUp:(id)sender {
    [self openBackUpFilePath];
}


- (IBAction)searchAnswer:(id)sender {
    NSSearchField * searchField = (NSSearchField *)sender;
    [self updateSearchKeyWord:[searchField stringValue]];
}

#pragma mark Back up operation
- (void)openBackUpFilePath {
    NSOpenPanel * panel = [NSOpenPanel openPanel];
    NSFileManager *fm = [NSFileManager defaultManager];
    [panel setDirectoryURL:[NSURL URLWithString:[fm currentDirectoryPath]]];
    [panel setAllowsMultipleSelection:NO];
    [panel setCanChooseDirectories:YES];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:YES];
    [panel setAllowedFileTypes:@[@"plist"]];
    [panel setAllowsOtherFileTypes:YES];
    if ([panel runModal] == NSModalResponseOK) {
        NSString * string = [panel.URLs.firstObject path];
        [self readPlistData:string];
    }
}

- (void)writeToBackFile {
    NSString *fileName = @"backup.plist";
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *path = [NSString stringWithFormat:@"%@/%@",[fm currentDirectoryPath],fileName];
    
    //判断文件是否存在 不存在就结束程序
    if([fm fileExistsAtPath:path]==NO){
        NSLog(@"文件不存在");
        [fm createFileAtPath:path contents:nil attributes:nil];
        
    }
    NSMutableArray * dataArray = [NSMutableArray array];
    for(ProblemEntity * entity in self.problemArray) {
        NSDictionary * dic = @{
                               @"problemId":entity.problemid,
                               @"problem":entity.problem,
                               @"answer":entity.answer,
                               @"type":entity.type
                               };
        [dataArray addObject:dic];
        
        
    }
    BOOL res = [dataArray writeToFile:path atomically:YES];
    if(res == YES) {
        [self showSuccess];
    }
//    [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:[fm currentDirectoryPath]];
}

- (void)showSuccess {
    
//    self.backupSuccessField.stringValue = @"备份成功!!!!!";
    if(!self.backUpAlert) {
        self.backUpAlert = [[NSAlert alloc]init];
    }
    self.backUpAlert.icon = [NSImage imageNamed:@"test_icon.png"];
    self.backUpAlert.messageText = @"备份成功";
    self.backUpAlert.informativeText = @"备份文件将会保存在程序所在的目录下，备份文件在恢复数据时将会起到非常重要的作用，希望能够妥善处理，经常保存。";
    [self.backUpAlert setAlertStyle:NSAlertStyleInformational];
    //回调Block
    [self.backUpAlert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
    }];
    [self performSelector:@selector(dismissSuccess) withObject:nil afterDelay:1];
}

- (void)dismissSuccess {
//    self.backUpAlert
    [NSApp endSheet:[self.view window]];
}

- (void)readPlistData:(NSString *)path {
    NSMutableArray *data = [[NSMutableArray alloc] initWithContentsOfFile:path];
    if(data) {
        NSInteger choiceCount = 0;
        NSInteger fillCount = 0;
        NSInteger judgeCount = 0;
        for(NSDictionary * dic in data) {
            NSString * str_type = [dic objectForKey:@"type"];
            if([str_type isEqualToString:@"选择题"]) {
                choiceCount++;
            } else if ([str_type isEqualToString:@"判断题"]) {
                judgeCount++;
            } else if ([str_type isEqualToString:@"填空题"]) {
                fillCount++;
            }
        }
        NSString *  str = [NSString stringWithFormat:@"备份题库包含选择题: %ld道,填空题: %ld道,判断题: %ld道。请选择数据恢复方式。",choiceCount,fillCount,judgeCount];
        [self showIfReadBackUpAlert:str withData:data];
    } else {
        
    }
}


#pragma mark Search Operation

- (void)updateSearchKeyWord:(NSString *)keyword{
    if(keyword.length == 0) {
        self.isInSearch = NO;
        [self.problemTableView reloadData];
    } else {
        self.isInSearch = YES;
        [self searchProblemWithString:keyword];
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

#pragma mark - Tableview delegate

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
    if(res == 1) {
        tableRow.backgroundColor = BackgroundColor;
    } else {
        tableRow.backgroundColor = [NSColor clearColor];
    }
    
    return view;
}

#pragma mark - Data operation

- (void)deleteData {
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

}

- (void)deleteAllData {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ProblemEntity" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:description];
    NSError *error = nil;
    NSArray *datas = [_context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count]) {
        for (ProblemEntity *obj in datas) {
            [_context deleteObject:obj];
        }
        if (![_context save:&error]) {
            NSLog(@"error:%@",error);
        }
    }
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:@"ProblemInfo" ofType:@"plist"];
    NSMutableDictionary *data = [[NSMutableDictionary alloc] initWithContentsOfFile:plistPath];
    [data setValue:@(0) forKey:@"lastMaxId"];
    [data writeToFile:plistPath atomically:YES];

}

- (void)insertData:(NSDictionary *)dictionary {
    ProblemEntity *p = [NSEntityDescription insertNewObjectForEntityForName:@"ProblemEntity" inManagedObjectContext:_context];
    NSString * strProblem = [dictionary objectForKey:@"problem"];
    NSNumber * numProblemId = [dictionary objectForKey:@"problemId"];
    NSString * strAnswer = [dictionary objectForKey:@"answer"];
    NSString * strType = [dictionary objectForKey:@"type"];
    p.problem = strProblem;
    p.problemid = numProblemId;
    p.type = strType;
    p.answer = strAnswer;
    NSError * error;
    [_context save:&error];
    if(error) {
        NSLog(@"Insert data Error");
    }
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

#pragma mark - Alert
- (void)showDeleteAllDataAlert {
    NSAlert *alert = [[NSAlert alloc]init];

    [alert addButtonWithTitle:@"确定"];
    [alert addButtonWithTitle:@"取消"];
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    alert.messageText = @"删除";
    alert.informativeText = @"确定删除所有题目？";
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

- (void)showIfReadBackUpAlert:(NSString *)showString withData:(NSArray *)dataArray{
    NSAlert *alert = [[NSAlert alloc]init];
    [alert addButtonWithTitle:@"添加"];
    [alert addButtonWithTitle:@"覆盖"];
    [alert addButtonWithTitle:@"取消"];
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    alert.messageText = @"读取备份";
    alert.informativeText = showString;
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            NSLog(@"添加");
            for(NSDictionary * dic in dataArray) {
                [self insertData:dic];
            }
        } else if (returnCode == NSAlertSecondButtonReturn){
            NSLog(@"覆盖");
            [self deleteAllData];
            for(NSDictionary * dic in dataArray) {
                [self insertData:dic];
            }
        } else if (returnCode == NSAlertThirdButtonReturn) {
            NSLog(@"取消");
        }
    }];
    [self allProblem];
    [self.problemTableView reloadData];
    self.currentSelectProblem = nil;

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
            [self deleteData];
            [self allProblem];
            [self.problemTableView reloadData];
            self.currentSelectProblem = nil;
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}

@end
