//
//  AddProblemViewController.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 17/2/10.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "AddProblemViewController.h"

@interface AddProblemViewController ()

@end

@implementation AddProblemViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
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
