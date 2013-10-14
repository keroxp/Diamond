//
//  DiamondCollectionTests.m
//  DiamondCollectionTests
//
//  Created by 桜井雄介 on 2013/10/12.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Kiwi.h>
#import "DIACollection.h"
#import "DIACollection+NSOrderedSet.h"
#import "DIACollection+NSKeyValueObserving.h"
#import "DIACollection+NSKeyValueCoding.h"
#import <objc/runtime.h>


SPEC_BEGIN(DiamondCollectionSpec)

describe(@"DiamondCollection", ^{
    __block DIACollection *collection;
    NSArray *array = @[@0,@1,@2,@3,@4];
    beforeEach(^{
        collection = [DIACollection new];
    });
    context(@"Runtime", ^{
        it(@"is subclass of NSObject", ^{
            [[collection should] beKindOfClass:[NSObject class]];
        });
        it(@"has completely same interface as NSArray", ^{
            DIACollection *col = [[DIACollection alloc] init];
            [[col shouldNot] raiseWithName:NSInvalidArgumentException whenSent:@selector(count)];
            [[theValue([col count]) should] beZero];
        });
    });
    context(@"on Add", ^{
        it(@"is possible to add a object", ^{
           [collection addObject:@1];
           [collection addObject:@[]];
           [collection addObject:@{}];
           [collection addObject:[NSObject new]];
           [[theBlock(^{
               [collection addObject:nil];
           }) should] raise];
           [collection addObject:[NSNull null]];
        });
        it(@"is possible to add multiple objects", ^{
            [collection addObjectsFromArray:array];
            [[theValue(collection.count) should] equal:theValue(5)];
        });
    });
    context(@"on Querying", ^{
        it(@"retruns correct count of contents", ^{
            [collection addObjectsFromArray:array];
            [[theValue(collection.count) should] equal:theValue(5)];
        });
        it(@"returns correct item", ^{
            [collection addObjectsFromArray:array];
            [[[collection objectAtIndex:2] should] equal:@2];
            [[collection[0] should] equal:@0];
        });
        it(@"returns correct index ", ^{
            [collection addObjectsFromArray:array];
            [[theValue([collection indexOfObject:@3]) should] equal:theValue(3)];
        });
        it(@"retuens first and last object", ^{
            [collection addObjectsFromArray:array];
            [[[collection firstObject] should] equal:@0];
            [[[collection lastObject] should] equal:@4];
        });
    });
    context(@"on Remove", ^{
        it(@"is possible to remove a object", ^{
           [collection addObjectsFromArray:array];
           [collection removeObject:@1];
           [[theValue(collection.count) should] equal:theValue(4)];
           [[theValue([collection indexOfObject:@1]) should] equal:theValue(NSNotFound)];
           [[collection[1] should] equal:@2];
        });
        it(@"is possible to remove a object at index", ^{
            [collection addObjectsFromArray:array];
            [collection removeObjectAtIndex:4];
            [[theValue(collection.count) should] equal:theValue(4)];
            [[theValue([collection indexOfObject:@4]) should] equal:theValue(NSNotFound)];
            [[collection[3] should] equal:@3];
        });
        it(@"is possdible to remove multible objects", ^{
            [collection addObjectsFromArray:array];
            [collection removeObjectsInArray:@[@1,@3,@4]];
            [[theValue(collection.count) should] equal:theValue(2)];
            NSOrderedSet *o = [NSOrderedSet orderedSetWithArray:@[@0,@2]];
            [[theValue([collection isEqualToOrderedSet:o]) should] equal:theValue(YES)];
        });
        it(@"is possible to remove multiple obejcts at indexes", ^{
            
        });
    });
    
});

SPEC_END
