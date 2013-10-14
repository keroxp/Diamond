//
//  DIADelegateChainSpec.m
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/12.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Kiwi.h>
#import "DIADelegateChain.h"

SPEC_BEGIN(DIADelegateChainSpec)

describe(@"DIADelegateChain", ^{
    __block  DIADelegateChain *chain;
    NSObject *dl1 = [NSObject new];
    NSObject *dl2 = [NSObject new];
    beforeEach(^{
        // refresh
        chain = [DIADelegateChain new];
    });
    // test instantiating
    context(@"on instantiated", ^{
       it(@"is successfully instantiated", ^{
           [[chain should] beKindOfClass:[NSObject class]];
           [[chain shouldNot] beNil];
       });
    });
    // test adding delegate
    context(@"on add", ^{
        it(@"is possible to add new delegate", ^{
            NSError *e =nil;
            [chain addDelegate:dl1 error:&e];
            // no error
            [[e should] beNil];
            // return delegates array
            [[[chain delegates] shouldNot] beNil];
            // and is NSArray
            [[chain delegates] isKindOfClass:[NSArray class]];
            // has one delegate
            [theValue([[chain delegates] count]) isEqualToKWValue:theValue(1)];
            // and that is dl1
            [[[[chain delegates] objectAtIndex:0] should] equal:dl1];
        });
    });
    // test removing delegate
    context(@"on remove", ^{
        it(@"is possible to remove delegate", ^{
            NSError *e =nil;
            [chain removeDelegate:dl1 error:&e];
            // no error
            [[e should] beNil];
            // has no delegate
            [[theValue([[chain delegates] count]) should] beZero];
        });
        it(@"is possible to add new delegate after removimg", ^{
            NSError *e =nil;
            // and add new delegate
            [chain addDelegate:dl2 error:&e];
            // is dl2
            [[[[chain delegates] objectAtIndex:0] should] equal:dl2];
            // is not dl1
            [[[[chain delegates] objectAtIndex:0] shouldNot] equal:dl1];
            // remove..
            [chain removeDelegate:dl2 error:&e];
        });
    });
    context(@"on adding delegats over maximum", ^{
        it(@"is possible", ^{
            NSMutableArray *dls = @[].mutableCopy;
            NSError *e = nil;
            for(NSUInteger i = 0 ; i < 10 ; i++){
                NSObject *dl = [NSObject new];
                [dls addObject:dl];
                [chain addDelegate:dl error:&e];
                [[e should] beNil];
            }
            for (NSUInteger i = 0; i < 10 ; i++){
                [[dls[i] should] equal:chain.delegates[i]];
            }
            NSObject *over = [NSObject new];
            [chain addDelegate:over error:&e];
            // memory space was correctly increased .
            [[theValue(chain.delegates.count) should] equal:theValue(11)];
            for(NSUInteger i = 0; i < chain.delegates.count - 1; i++){
                [[[chain.delegates objectAtIndex:i] should] equal:dls[i]];
            }
        });
    });
    context(@"on adding iregular objects", ^{
        it(@"is possible to add not NSObject", ^{
            NSError *e = nil;
            [chain addDelegate:@1 error:&e];
            [chain addDelegate:@(YES) error:&e];
            [chain addDelegate:[NSNull null] error:&e];
            [[e should] beNil];
            [[theValue(chain.delegates.count) should] equal:theValue(3)];
            [[[[chain delegates] objectAtIndex:0] should] equal:@1];
            [[[[chain delegates] objectAtIndex:1] should] equal:@(YES)];
            [[[[chain delegates] objectAtIndex:2] should] equal:[NSNull null]];
        });
    });
    context(@"on execute delegate methods", ^{
       it(@"is successfully published", ^{
           // add NSArray (not NSObject)
           for(NSUInteger i = 0;  i < 5; i++){
               [chain addDelegate:[NSArray new] error:nil];
           }
           // call NSArray's Method
           [[chain shouldNot] raiseWhenSent:@selector(count)];
       });
    });
});

SPEC_END
