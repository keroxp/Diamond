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

NSArray *array = @[@0,@1,@2,@3,@4];
__block DIACollection *collection;

describe(@"-init", ^{
    beforeEach(^{
        collection = [DIACollection new];
    });
    context(@":", ^{
        it(@"shuold return instance", ^{
            [[collection shouldNot] beNil];
            [[collection should] beKindOfClass:[NSObject class]];
        });
    });
});

describe(@"-add", ^{
    beforeEach(^{
        collection = [DIACollection new];
    });
    context(@"Object:", ^{
        it(@"should not raise when adding object", ^{
            [[theBlock(^{
                [collection addObject:@1];
                [collection addObject:@[]];
                [collection addObject:@{}];
                [collection addObject:[NSObject new]];
                [collection addObject:[NSNull null]];
            }) shouldNot] raise];
        });
        it(@"should raise when adding nil", ^{
            [[theBlock(^{
                [collection addObject:nil];
            }) should] raise];
        });
    });
    context(@"ObjectsFromArray:", ^{
        it(@"shuold add objects correctly", ^{
            [[theBlock(^{
                [collection addObjectsFromArray:array];
            }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(5)];
        });
    });
});

describe(@"-remove", ^{
    beforeEach(^{
        collection = [DIACollection collectionWithArray:array error:nil];
    });
    context(@"Object:", ^{
        it(@"should remove object", ^{
            [collection removeObject:@1];
            [[theValue(collection.count) should] equal:theValue(4)];
            [[theValue([collection indexOfObject:@1]) should] equal:theValue(NSNotFound)];
            [[collection[1] should] equal:@2];
        });
    });
    context(@"ObjectAtIndex:", ^{
        it(@"should remove object at index", ^{
            [[theBlock(^{
                [collection removeObjectAtIndex:4];
            }) shouldNot] raise];
            [[theValue(collection.count) should] equal:theValue(4)];
            [[theValue([collection indexOfObject:@4]) should] equal:theValue(NSNotFound)];
            [[collection[3] should] equal:@3];
        });
    });
    context(@"ObjectsInArray:", ^{
        [collection removeObjectsInArray:@[@1,@3,@4]];
        [[theValue(collection.count) should] equal:theValue(2)];
        NSOrderedSet *o = [NSOrderedSet orderedSetWithArray:@[@0,@2]];
        [[theValue([collection isEqualToOrderedSet:o]) should] equal:theValue(YES)];
    });
    context(@"ObjectsAtIndexes:", ^{
        it(@"", ^{
            // 0,1,2,3,4 => 3,4
            NSIndexSet *is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 3)];
            [collection removeObjectsAtIndexes:is];
            [[theValue(collection.count) should] equal:theValue(2)];
            [[[collection firstObject] should] equal:@3];
            [[[collection lastObject] should] equal:@4];
        });
        it(@"", ^{
            // 0,1,2,3,4 => 0,1
            NSIndexSet *is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 3)];
            [collection removeObjectsAtIndexes:is];
            [[theValue(collection.count) should] equal:theValue(2)];
            [[[collection firstObject] should] equal:@0];
            [[[collection lastObject] should] equal:@1];
        });
        it(@"", ^{
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
    });
    context(@"ObjectsPassingTest:", ^{
        it(@"shuold work", ^{
            [collection removeObjectsPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
            // remove even numbers
            return (obj.unsignedIntegerValue%2 == 0);
            }];
            [[theValue(collection.count) should] equal:theValue(2)];
            NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@3]];
            [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
        });
    });
    context(@"AllObjects", ^{
        it(@"should work", ^{
            [[theValue(collection.count) should] equal:theValue(5)];
            [collection removeAllObjects];
            [[theValue(collection.count) should] equal:theValue(0)];
        });
    });
});

describe(@"on querying", ^{
    beforeEach(^{
        collection = [DIACollection collectionWithArray:array error:nil];
    });
    context(@"on Querying", ^{
        it(@"should returns correct item", ^{
            [[[collection objectAtIndex:2] should] equal:@2];
            [[collection[0] should] equal:@0];
        });
        it(@"should returns correct index ", ^{
            [[theValue([collection indexOfObject:@3]) should] equal:theValue(3)];
        });
        it(@"shuold retuens first and last object", ^{
            [[[collection firstObject] should] equal:@0];
            [[[collection lastObject] should] equal:@4];
        });
    });
});

describe(@"-hide", ^{
    beforeEach(^{
        collection = [DIACollection collectionWithArray:array error:nil];
    });
    context(@"Object:", ^{
       it(@"shuold work", ^{
           [[theBlock(^{
               [collection hideObject:@2];
               [collection hideObject:@0];
           }) shouldNot] raise];
           [[theValue(collection.count) should] equal:theValue(3)];
           [[theValue(collection.actualOrderedSet.count) should] equal:theValue(5)];
           NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@3,@4]];
           [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
       });
    });
    context(@"ObjectsInArray:", ^{
        // 0,1,2,3,4 => (0),(1),2,(3),(4)
       [[theBlock(^{
           [collection hideObjectsInArray:@[@4,@3,@0,@1]];
       }) shouldNot] raise];
        [[theValue(collection.count) should] equal:theValue(1)];
        [[theValue(collection.actualOrderedSet.count) should] equal:theValue(5)];
        NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@2]];
        [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
    });
    context(@"ObjectAtIndex:", ^{
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
        [[theValue(collection.actualOrderedSet.count) should] equal:theValue(5)];
        NSOrderedSet *os = [NSOrderedSet orderedSetWithArray:@[@1,@2,@3]];
        [[theValue([collection isEqualToOrderedSet:os]) should] equal:theValue(YES)];
    });
    context(@"ObjectsAtIndexes", ^{
       [[theBlock(^{
           NSMutableIndexSet *is = [NSMutableIndexSet indexSet];
           [is addIndex:0];
           [is addIndex:4];
           [is addIndex:1];
           [collection hideObjectsAtIndexes:is];
       }) shouldNot] raise];
    });
    context(@"ObjectsPassingTest:", ^{
        // 0,1,2,3,4 => (0),1,(2),3,(4)
       [[theBlock(^{
           [collection hideObjectsPassingTest:^BOOL(NSNumber *obj, NSUInteger idx, BOOL *stop) {
               return (obj.unsignedIntegerValue%2 == 0);
           }];
       }) shouldNot] raise];
        [[theValue(collection.count) should] equal:theValue(2)];
        [[theValue(collection.actualOrderedSet.count) should] equal:theValue(5)];
        [[theValue(collection.hiddenOrderedSet.count) should] equal:theValue(3)];
        // only odd numbres left
        for (NSNumber *i in collection){
            [[theValue(i.unsignedIntegerValue%2) shouldNot] beZero];
        }
    });
});

describe(@"-unHide", ^{
    beforeEach(^{
        collection = [DIACollection collectionWithArray:array error:nil];
    });
    context(@"Object:", ^{
      it(@"should work", ^{
          [collection hideObject:@1];
          [[theValue([collection containsObject:@1]) should] beFalse];
          [collection unHideObject:@1];
          [[theValue([collection containsObject:@1]) should] beTrue];
          [[[collection lastObject] should] equal:@1];
      });
    });
    context(@"ObjectsInArray:", ^{
       it(@"should work", ^{
           // 0,1,2,3,4 => (0),(1),(2),(3),(4)
           [collection hideObjectsInArray:array];
           NSArray *arr = @[@0,@2,@4,@5];
           [collection unHideObjectsInArray:arr];
           // => 0,(1),2,(3),4
           [[theValue(collection.count) should] equal:theValue(3)];
           [[theValue(collection.hiddenOrderedSet.count) should] equal:theValue(2)];
           [[theValue(collection.actualOrderedSet.count) should] equal:theValue(5)];
           [[[collection firstObject] should] equal:@0];
           [[[collection lastObject] should] equal:@4];
       });
    });
});

SPEC_END
