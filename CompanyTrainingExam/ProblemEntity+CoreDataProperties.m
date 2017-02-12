//
//  ProblemEntity+CoreDataProperties.m
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 2017/2/11.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "ProblemEntity+CoreDataProperties.h"

@implementation ProblemEntity (CoreDataProperties)

+ (NSFetchRequest<ProblemEntity *> *)fetchRequest {
	return [[NSFetchRequest alloc] initWithEntityName:@"ProblemEntity"];
}

@dynamic problemid;
@dynamic answer;
@dynamic problem;
@dynamic type;

@end
