//
//  DIAPokemonSpec.m
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/21.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Kiwi.h>
#import "Pokemon.h"

SPEC_BEGIN(DIAPokemonSpec)

describe(@"Pokemon", ^{
   it(@"should have properties", ^{
       NSString *s = @"{\"name\":\"フシギダネ\",\"type\":[\"くさ\",\"どく\"],\"hp\":45,\"attack\":49,\"defence\":49,\"sattack\":65,\"sdefence\":65,\"speed\":45,\"ability\":[\"しんりょく\"]}";
       NSDictionary *d = [NSJSONSerialization JSONObjectWithData:[s dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
       [[d shouldNot] beNil];
       [[theBlock(^{
           Pokemon *p = [[Pokemon alloc] initWithDictionary:d];
           [[[p name] shouldNot] beNil];
           [[theValue(p.attack) shouldNot] beZero];
           [[theValue(p.defence) shouldNot] beZero];
           [[theValue(p.sattack) shouldNot] beZero];
           [[theValue(p.sdefence) shouldNot] beZero];
           [[theValue(p.speed) shouldNot] beZero];
           [[[p abilities] shouldNot] beNil];
           [[[p types] shouldNot] beNil];
       }) shouldNot] raise];
   });
});

SPEC_END

