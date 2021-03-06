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
#import "NSTextField(copypast).h"
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
@property (nonatomic, assign) BOOL isEditing;
@property (nonatomic, assign) NSInteger clickTimes;
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
    [self.problemTableView setDoubleAction:@selector(doubleClickAtIndex:)];
    _isInSearch = NO;
    _isEditing = NO;
    _clickTimes = 0;
    self.searchResArray = [NSMutableArray array];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view setWantsLayer:YES];
    [self.view.layer setBackgroundColor:[BackgroundColor CGColor]];
//    self.editView.hidden = YES;
}

- (void)viewDidAppear {
    [super viewDidAppear];
    
    [self allProblem];
    if(self.problemTableView) {
        [self.problemTableView reloadData];
    }
    
}
#pragma mark action
- (void) doubleClickAtIndex:(id)sender {
    NSTableView * tableView = (NSTableView *)sender;
    if(tableView.selectedRow >= 0) {
        ProblemEntity * entity = [self.problemArray objectAtIndex:tableView.selectedRow];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
}

- (IBAction)buttonClicked:(id)sender {
    if(_isEditing == YES) {
        [self editData];
    } else {
        [self addProblem];
    }
    
}

- (IBAction)editProblem:(id)sender {
    if(_isEditing == YES) {
        _isEditing = NO;
        [self.okButton setTitle:@"添加"];
        [self.editButton setTitle:@"编辑"];
        self.textField.stringValue = @"";
        self.answerField.stringValue = @"";
        [self.tagField selectItemAtIndex:0];
    } else {
        if(self.currentSelectProblem) {
            _isEditing = YES;
            [self.okButton setTitle:@"修改"];
            [self.editButton setTitle:@"取消编辑"];
            
            
            
            self.textField.stringValue = self.currentSelectProblem.problem;
            self.answerField.stringValue = self.currentSelectProblem.answer;
            NSString * str_type = self.currentSelectProblem.type;
            NSInteger typeIndex = 0;
            if([str_type isEqualToString:@"选择题"]) {
                typeIndex = 0;
            } else if ([str_type isEqualToString:@"填空题"]) {
                typeIndex = 1;
            } else if ([str_type isEqualToString:@"论述题"]) {
                typeIndex = 2;
            }
            [self.tagField selectItemAtIndex:typeIndex];
            
        } else {
            [self noticAlertWithString:@"还未选定题目。"];
        }
    }
    
}

- (IBAction)searchFieldBecomeFristResponse:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"SearchData" object:self];
}

- (void)searchFieldBecomeFristResponse {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    self.searchField.stringValue = @" ";
    [self.searchField becomeFirstResponder];
    
}

- (IBAction)deleteAllData:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"DeleteData" object:self];
}



- (IBAction)freshDataClicked:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    _clickTimes++;
    if(_clickTimes < 2) {
        self.searchField.stringValue = @"";
        self.isInSearch = NO;
        [self allProblem];
        self.currentSelectProblem = nil;
        [self.problemTableView reloadData];
    } else {
        [self noticAlertWithString:@"当前操作太快，请稍作休息再试"];
        _clickTimes = 0;
    }
    
}

- (IBAction)deleteData:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    if(self.currentSelectProblem) {
        [self showDeleteAlert];
    } else {
        [self noticAlertWithString:@"还未选定题目。"];
    }
    
}

- (IBAction)backUp:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"BackUpData" object:self];
    
}


- (IBAction)readBackUp:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
    [self openBackUpFilePath];
}


- (IBAction)searchAnswer:(id)sender {
    if(_isEditing == YES) {
        [self noticAlertWithString:@"当前正在编辑中，请取消编辑后再操作。"];
        return;
    }
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
            } else if ([str_type isEqualToString:@"论述题"]) {
                judgeCount++;
            } else if ([str_type isEqualToString:@"填空题"]) {
                fillCount++;
            }
        }
        NSString *  str = [NSString stringWithFormat:@"备份题库包含选择题: %ld道,填空题: %ld道,论述题: %ld道。请选择数据恢复方式。",choiceCount,fillCount,judgeCount];
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
        } else if([entity.type isEqualToString:@"论述题"]) {
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
    if(_isEditing == YES) {
        return NO;
    } else {
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
                tableRow.layer.masksToBounds = NO;
                tableRow.layer.borderWidth = 0;
                tableRow.layer.borderColor = [NSColor clearColor].CGColor;
            }
        }
        return YES;
    }
    
    
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
    tableRow.layer.masksToBounds = NO;
    tableRow.layer.borderWidth = 0;
    tableRow.layer.borderColor = [NSColor clearColor].CGColor;
    
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
- (void)editData {
    NSEntityDescription *description = [NSEntityDescription entityForName:@"ProblemEntity" inManagedObjectContext:_context];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setIncludesPropertyValues:NO];
    [request setEntity:description];
    NSError *error = nil;
    NSArray *datas = [_context executeFetchRequest:request error:&error];
    if (!error && datas && [datas count]) {
        for (ProblemEntity *obj in datas) {
            if(obj.problemid.integerValue == self.currentSelectProblem.problemid.integerValue) {
                obj.problem = self.textField.stringValue;
                obj.answer = self.answerField.stringValue;
                
                obj.type = self.tagField.selectedItem.title;
            }
        }
        if (![_context save:&error]) {
            NSLog(@"error:%@",error);
        }
    }
    [self editProblem:nil];
    [self allProblem];
    [self.problemTableView reloadData];
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
    NSError * error = nil;
    self.problemArray = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
    if(error == nil){
        [self count];
    }
    
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

- (void)noticAlertWithString:(NSString *)string {
    NSAlert *alert = [[NSAlert alloc]init];
    
    alert.icon = [NSImage imageNamed:@"test_icon.png"];
    
    [alert addButtonWithTitle:@"确认"];
    
    alert.messageText = @"提示";
    
    alert.informativeText = string;
    
    [alert setAlertStyle:NSAlertStyleWarning];
    
    [alert beginSheetModalForWindow:[self.view window] completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn ) {
            
        }else if (returnCode == NSAlertSecondButtonReturn){
            
        }
    }];
}



/**
 新增个人记录
 */
- (void)addProblem {
    if(self.textField.stringValue.length == 0 ||
       self.answerField.stringValue.length == 0) {
        [self noticAlertWithString:@"未输入问题或者答案，请输入后再提交。"];
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



@end
