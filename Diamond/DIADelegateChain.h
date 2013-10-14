//
//  DIADelegateChain.h
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/12.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//
// from :
// http://www.xs-labs.com/en/archives/articles/cocoa-delegate-chain/

#import <Foundation/Foundation.h>

@interface DIADelegateChain : NSObject

- (void)addDelegate:(id)delegate;
- (void)removeDelegate:(id)delegate;
- (NSArray*)delegates;

@end
