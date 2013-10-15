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
    __block DIACollection *emptyCollection;
    NSArray *array = @[@0,@1,@2,@3,@4];
    beforeEach(^{
        NSError *e = nil;
        collection = [DIACollection collectionWithArray:array error:&e];
        emptyCollection = [DIACollection new];
    });
    context(@"Runtime", ^{
        it(@"is subclass of NSObject", ^{
            [[emptyCollection should] beKindOfClass:[NSObject class]];
        });
        it(@"has completely same interface as NSArray", ^{
            [[emptyCollection shouldNot] raiseWithName:NSInvalidArgumentException whenSent:@selector(count)];
            [[theValue([emptyCollection count]) should] beZero];
        });
    });
    context(@"-add", ^{
        it(@"Object:", ^{
           [emptyCollection addObject:@1];
           [emptyCollection addObject:@[]];
           [emptyCollection addObject:@{}];
           [emptyCollection addObject:[NSObject new]];
           [[theBlock(^{
               [emptyCollection addObject:nil];
           }) should] raise];
            [emptyCollection addObject:[NSNull null]];
        });
        it(@"ObjectsFromArray:", ^{
            [emptyCollection addObjectsFromArray:array];
            [[theValue(collection.count) should] equal:theValue(5)];
        });
    });
    context(@"on Querying", ^{
        it(@"returns correct item", ^{
            [[[collection objectAtIndex:2] should] equal:@2];
            [[collection[0] should] equal:@0];
        });
        it(@"returns correct index ", ^{
            [[theValue([collection indexOfObject:@3]) should] equal:theValue(3)];
        });
        it(@"retuens first and last object", ^{
            [[[collection firstObject] should] equal:@0];
            [[[collection lastObject] should] equal:@4];
        });
    });
    context(@"-remove", ^{
        it(@"Object:", ^{
           [collection removeObject:@1];
           [[theValue(collection.count) should] equal:theValue(4)];
           [[theValue([collection indexOfObject:@1]) should] equal:theValue(NSNotFound)];
           [[collection[1] should] equal:@2];
        });
        it(@"ObjectAtIndex:", ^{
            [collection removeObjectAtIndex:4];
            [[theValue(collection.count) should] equal:theValue(4)];
            [[theValue([collection indexOfObject:@4]) should] equal:theValue(NSNotFound)];
            [[collection[3] should] equal:@3];
        });
        it(@"ObjectsInArray:", ^{
            [collection removeObjectsInArray:@[@1,@3,@4]];
            [[theValue(collection.count) should] equal:theValue(2)];
            NSOrderedSet *o = [NSOrderedSet orderedSetWithArray:@[@0,@2]];
            [[theValue([collection isEqualToOrderedSet:o]) should] equal:theValue(YES)];
        });
        it(@"ObjectsAtIndexes: 1", ^{
            // 0,1,2,3,4 => 3,4
            NSIndexSet *is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
            [collection removeObjectsAtIndexes:is];
            [[theValue(collection.count) should] equal:theValue(2)];
            [[[collection firstObject] should] equal:@3];
            [[[collection lastObject] should] equal:@4];
        });
        it(@"ObjectsAtIndexes: 2", ^{
            // 0,1,2,3,4 => 0,1
            NSIndexSet *is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)];
            [collection removeObjectsAtIndexes:is];
            [[theValue(collection.count) should] equal:theValue(2)];
            [[[collection firstObject] should] equal:@0];
            [[[collection lastObject] should] equal:@1];
        });
        it(@"ObjectsAtIndexes: 3", ^{
            // 0,1,2,3,4 =? 1,3,4
            NSMutableIndexSet *mis = [NSMutableIndexSet indexSet];
            [mis addIndex:0];
            [mis addIndex:2];
            [[theBlock(^{
                [collection removeObjectsAtIndexes:mis];
            }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(3)];
            [[collection[0] should] equal:@1];
            [[collection[1] should] equal:@3];
            [[collection[2] should] equal:@4];
        });
        it(@"ObjectsPassingTest:", ^{
            [collection removeObjectsPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                // remove even numbers
                return (obj.unsignedIntegerValue%2 == 0);
            }];
            [[theValue(collection.count) should] equal:theValue(2)];
            NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@3]];
            [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
        });
        it(@"AllObjects", ^{
            [[theValue(collection.count) should] equal:theValue(5)];
            [collection removeAllObjects];
            [[theValue(collection.count) should] equal:theValue(0)];
        });
    });
    context(@"-onHide", ^{
       it(@"Object:", ^{
           [[theBlock(^{
               [collection hideObject:@2];
               [collection hideObject:@0];
           }) shouldNot] raise];
           [[theValue(collection.count) should] equal:theValue(3)];
           [[theValue(collection.actualArray.count) should] equal:theValue(5)];
           NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@3,@4]];
           [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
       });
        it(@"ObjectsInArray:", ^{
            // 0,1,2,3,4 => (0),(1),2,(3),(4)
           [[theBlock(^{
               [collection hideObjectsInArray:@[@4,@3,@0,@1]];
           }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(1)];
            [[theValue(collection.actualArray.count) should] equal:theValue(5)];
            NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@2]];
            [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
        });
        it(@"ObjectAtIndex:", ^{
           [[theBlock(^{
               // 0,1,2,3,4 => (0),1,2,3,4
               [collection hideObjectAtIndex:0];
           }) shouldNot] raise];
            [[theBlock(^{
               // (0),1,2,3,4 => NSRangeException
                [collection hideObjectAtIndex:4];
            }) should] raise];
            [[theBlock(^{
                // (0),1,2,3,4 => (0),1,2,3,(4)
                [collection hideObjectAtIndex:3];
            }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(3)];
            [[theValue(collection.actualArray.count) should] equal:theValue(5)];
            NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@2,@3]];
            [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
        });
        it(@"ObjectsAtIndexes", ^{
           [[theBlock(^{
               NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
               [is addIndex:0];
               [is addIndex:4];
               [is addIndex:1];
               [collection hideObjectsAtIndexes:is];
           }) shouldNot] raise];
        });
        it(@"ObjectsPassingTest:", ^{
            // 0,1,2,3,4 => (0),1,(2),3,(4)
           [[theBlock(^{
               [collection hideObjectsPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
                   return (obj.unsignedIntegerValue%2 == 0);
               }];
           }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(2)];
            [[theValue(collection.actualArray.count) should] equal:theValue(5)];
            [[theValue(collection.hiddenOrderedSet.count) should] equal:theValue(3)];
            // only odd numbres left
            for (NSNumber *i in collection){
                [[theValue(i.unsignedIntegerValue%2) shouldNot] beZero];
            }
        });
    });
});

SPEC_END
