//
//  DIACollection.h
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/10.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

// DIACollection is kind of NSObject,
// however, it behavirs almost same as NSOrderedSet with custom mutation mthods.

#import <Foundation/Foundation.h>

@protocol DIACollectionMutationDelegate;

typedef enum : NSUInteger {
    DIACollectionMutationReasonNone = 0,
    DIACollectionMutationReasonAdd = 100,
    DIACollectionMutationReasonPush,
    DIACollectionMutationReasonInsert,
    DIACollectionMutationReasonUnHidden,
    DIACollectionMutationReasonRemove = 200,
    DIACollectionMutationReasonFiltered,
    DIACollectionMutationReasonHidden,
    DIACollectionMutationReasonReplace = 300,
    DIACollectionMutationReasonExchange
}DIACollectionMutationReason;

@interface DIACollection : NSObject

/** Creating Collection */

+ (instancetype)collectionWithArray:(NSArray*)array error:(NSError**)error;
- (instancetype)initWithArray:(NSArray*)array error:(NSError**)error;

/** Adding Object */

// add object to the collection consistent with inner sort description.
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray*)array;
// push object to the last location ignoring inner sort description.
// calling these method may causes inner inconsistency of order.
// you can solve it with -sort: method.
- (void)pushObject:(id)object;
- (void)pushObjectsFromArray:(NSArray*)array;
// insert object to the collection at supecified index.
// these also ignore inner sort descriptions.
- (void)insertObject:(id)object atIndex:(NSUInteger)index;
- (void)insertObjects:(NSArray*)array atIndexes:(NSIndexSet*)indexes;

/** Removing Object */

// remove object at specified index of visible range, and actual data
- (void)removeObjectAtIndex:(NSUInteger)index;
// remove object from visible range by using removeObjectAtIndex: with isEqual: method.
- (void)removeObject:(id)object;
- (void)removeObjectsInArray:(NSArray*)array;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes;
// remove all objects at specified indexes.
// if you want to remove all objects with internal equality,use this
// with "return [toBeRemoved isEqual:obj];" in block.
- (void)removeObjectsPassingTest:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))predicate;
// remove all objects from collection, including visible, actual, hidden, filterd range.
- (void)removeAllObjects;

/** Moving Objects  */

- (void)moveObject:(id)object beforeObject:(id)beforeObject;
- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;

/** Exchange Objects */

- (void)exchangeObject:(id)obj1 WithObject:(id)obj2;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

/** Replacing Objects */

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object;
- (void)replaceObjectsAtIndexes:(NSIndexSet*)indexes withObjects:(NSArray *)objects;

/** Hiding Object */

- (void)hideObject:(id)object;
- (void)hideObjectsInArray:(NSArray*)array;
- (void)hideObjectAtIndex:(NSUInteger)index;
- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)hideObjectsPassingTest:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))predicate;

/** Unhiding Objects */

- (void)unHideObject:(id)object;
- (void)unHideObjectsInArray:(NSArray*)array;
- (void)unHideObjectsPassingTest:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))predicate;
- (void)unhideAllObjects;

/** Observing Inner Mutation */

// Add an observer object for the collection.
// It must conform to DIACollectionMutationDelegate protocol
// and will be refered weakly.
// Collection doesn't have a strong reference to the delegator.
// You can add multiple observer from any other classes.
// Collection points observer by wrapping NSValue+unretainedObjectValue.
- (void)addDelegate:(id<DIACollectionMutationDelegate>)delegate;
// Remove the observer for the collection.
- (void)removeDelegate:(id<DIACollectionMutationDelegate>)delegate;
// delegate obejcts
- (NSArray*)delegates;

/** Sorting Objects */

- (void)sort;
@property (nonatomic, copy) NSArray *sortDescriptors;

/** Filtering Objects */
@property (nonatomic, copy) NSArray *filterPredicates;

/** Array Representation */

- (NSArray *)array;

/** OrderedSet Representation */

- (NSOrderedSet *)actualOrderedSet;
- (NSOrderedSet *)orderedSet;
- (NSOrderedSet *)filteredOrderedSet;
- (NSOrderedSet *)hiddenOrderedSet;

@end

@protocol DIACollectionMutationDelegate <NSObject>

- (void)collectionWillChangeContent:(DIACollection*)collection;

- (void)collection:(DIACollection*)collection didInsertObject:(id)object atIndex:(NSUInteger)index forReason:(DIACollectionMutationReason)reason;
- (void)collection:(DIACollection*)collection didDeleteObject:(id)object atIndex:(NSUInteger)index forReason:(DIACollectionMutationReason)reason;
- (void)collection:(DIACollection*)collection didMoveObject:(id)object fromIndex:(NSUInteger)fromIndex  toIndex:(NSUInteger)toIndex forReason:(DIACollectionMutationReason)reason;
- (void)collection:(DIACollection*)collection didUpdateObject:(id)object atIndex:(NSUInteger)index forReason:(DIACollectionMutationReason)reason;
- (void)collection:(DIACollection*)collection didChangeSortWithSortDescriptros:(NSArray*)sortDescriptors;

- (void)collectioDidChangeContent:(DIACollection*)collection;

@end

@interface DIACollection (NSOrderedSetProtocol)
<NSCopying, NSSecureCoding, NSFastEnumeration>

@end
