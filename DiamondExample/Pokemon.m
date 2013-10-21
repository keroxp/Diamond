//
//  Pokemon.m
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/21.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "Pokemon.h"

@implementation Pokemon

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        _name = dictionary[@"name"];
        _attack = [dictionary[@"attack"] unsignedIntegerValue];
        _defence = [dictionary[@"defence"] unsignedIntegerValue];
        _sattack = [dictionary[@"sattack"] unsignedIntegerValue];
        _sdefence = [dictionary[@"sdefence"] unsignedIntegerValue];
        _speed = [dictionary[@"speed"] unsignedIntegerValue];
        _abilities = dictionary[@"ability"];
        _types = dictionary[@"type"];
    }
    return self;
}

@end
