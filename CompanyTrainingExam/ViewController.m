//
//  ViewController.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "ViewController.h"
@interface ViewController() <NSTextFieldDelegate>
@property (nonatomic,strong) NSString * textFieldValue;
@end
@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

- (IBAction)buttonClicked:(id)sender {
    NSLog(@"Click success:%@",self.textField.stringValue);
    NSDictionary * problem = @{
                               @"Problem":self.textField.stringValue,
                               @"Answer":self.answerField.stringValue,
                               @"Tag":self.tagField.stringValue
                               };
    NSLog(@"problem:\n%@",problem);
}


@end
