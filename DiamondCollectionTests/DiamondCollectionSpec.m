//
//  DiamondCollectionTests.m
//  DiamondCollectionTests
//
//  Created by 桜井雄介 on 2013/10/12.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Kiwi.h>
#import "DIACollection.h"
#import "DIACollection+NSArray.h"
#import "DIACollection+NSKeyValueObserverRegistration.h"
#import <objc/runtime.h>


SPEC_BEGIN(DiamondCollectionSpec)

describe(@"DiamondCollection", ^{
    context(@"Runtime", ^{
        it(@"is subclass of NSObject", ^{
            DIACollection *col = [[DIACollection alloc] init];
            [[col should] beKindOfClass:[NSObject class]];
        });
        it(@"has completely same interface as NSArray", ^{
            DIACollection *col = [[DIACollection alloc] init];
            [[col shouldNot] raiseWithName:NSInvalidArgumentException whenSent:@selector(count)];
            [[theValue([col count]) should] beZero];
        });
    });
});

SPEC_END
