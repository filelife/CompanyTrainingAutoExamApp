//
//  ProblemEntity+CoreDataProperties.h
//  CompanyTrainingExam
//
//  Created by Gejiaxin on 2017/2/11.
//  Copyright © 2017年 VincentJac. All rights reserved.
//

#import "ProblemEntity+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ProblemEntity (CoreDataProperties)

+ (NSFetchRequest<ProblemEntity *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSNumber *problemid;
@property (nullable, nonatomic, copy) NSString *answer;
@property (nullable, nonatomic, copy) NSString *problem;
@property (nullable, nonatomic, copy) NSString *type;

@end

NS_ASSUME_NONNULL_END
