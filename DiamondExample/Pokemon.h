//
//  Pokemon.h
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/21.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

/*
 {"name":"フシギダネ","type":["くさ","どく"],"hp":45,"attack":49,"defence":49,"sattack":65,"sdefence":65,"speed":45,"ability":["しんりょく"]}
 */

#import <Foundation/Foundation.h>

@interface Pokemon : NSObject

- (instancetype)initWithDictionary:(NSDictionary*)dictionary;

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSArray *types;
@property (nonatomic, readonly) NSUInteger attack;
@property (nonatomic, readonly) NSUInteger defence;
@property (nonatomic, readonly) NSUInteger sattack;
@property (nonatomic, readonly) NSUInteger sdefence;
@property (nonatomic, readonly) NSUInteger speed;
@property (nonatomic, copy, readonly) NSArray *abilities;

@end
