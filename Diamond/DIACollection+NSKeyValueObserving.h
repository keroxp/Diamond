//
//  DIACollection+NSKeyValueObserverRegistration.h
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/13.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIACollection.h"

@interface DIACollection (NSKeyValueObserving)

/* NSOrderedSets are not observable, so these methods raise exceptions when invoked on NSOrderedSets. Instead of observing an ordered set, observe the ordered to-many relationship for which the ordered set is the collection of related objects.
 */
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context NS_AVAILABLE(10_7, 5_0);
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
