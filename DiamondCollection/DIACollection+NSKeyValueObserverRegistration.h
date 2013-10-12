//
//  DIACollection+NSKeyValueObserverRegistration.h
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/13.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIACollection.h"

@interface DIACollection (NSKeyValueObserverRegistration)

/* Register or deregister as an observer of the values at a key path relative to each indexed element of the array. The options determine what is included in observer notifications and when they're sent, as described above, and the context is passed in observer notifications as described above. These are not merely convenience methods; invoking them is potentially much faster than repeatedly invoking NSObject(NSKeyValueObserverRegistration) methods. You should use -removeObserver:fromObjectsAtIndexes:forKeyPath:context: instead of -removeObserver:fromObjectsAtIndexes:forKeyPath: whenever possible for the same reason described in the NSObject(NSKeyValueObserverRegistration) comment.
 */

- (void)addObserver:(NSObject *)observer toObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath context:(void *)context NS_AVAILABLE(10_7, 5_0);
- (void)removeObserver:(NSObject *)observer fromObjectsAtIndexes:(NSIndexSet *)indexes forKeyPath:(NSString *)keyPath;

/* NSArrays are not observable, so these methods raise exceptions when invoked on NSArrays. Instead of observing an array, observe the ordered to-many relationship for which the array is the collection of related objects.
 */
- (void)addObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath options:(NSKeyValueObservingOptions)options context:(void *)context;
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath context:(void *)context NS_AVAILABLE(10_7, 5_0);
- (void)removeObserver:(NSObject *)observer forKeyPath:(NSString *)keyPath;

@end
