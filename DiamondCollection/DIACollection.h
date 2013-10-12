//
//  DIACollection.h
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/10.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DIAModel;

@protocol DIACollectionMutationDelegate;

// A type of mutation which occured in the colletion
// It is actually same as NSFetchResultChangeType.
typedef enum : NSUInteger{
    DIACollectionMutationTypeAdd,
    DIACollectionMutationTypeRemove,
    DIACollectionMutationTypeMove,
    DIACollectionMutationTypeSort,
    DIACollectionMutationTypeHidden
}DIACollectionMutationType;

@interface DIACollection : NSObject <NSCopying, NSSecureCoding, NSFastEnumeration>

/** Creating Collection */

+ (instancetype)collectionWithArray:(NSArray*)array error:(NSError**)error;
- (instancetype)initWithArray:(NSArray*)array error:(NSError**)error;

/** Adding Object */

// add object to collection consistent with inner sort description.
- (void)addObject:(id)object;
- (void)addObjectsFromArray:(NSArray*)array;
// push object to the last location ignoring inner sort description.
// calling these method may causes inner inconsistency of order.
// you can solve it with -sort: method.
- (void)pushObject:(id)object;
- (void)pushObjectsFromArray:(NSArray*)array;

/** Removing Object */

- (void)removeObject:(id)object;
- (void)removeObjectsInArray:(NSArray*)array;
- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes;

/** Moving Objects  */

- (void)moveObject:(id)object beforeObject:(id)beforeObject;
- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)exchangeObject:(id)obj1 WithObject:(id)obj2;
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2;

/** Hiding Object */

- (void)hideObject:(id)object;
- (void)hideObjectAtIndex:(NSUInteger)index;
- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)unHideObject:(id)object;
- (void)unHideObjectAtIndex:(NSUInteger)index;
- (void)unHideObjectsAtIndexes:(NSIndexSet*)indexes;

/** Observing Inner Mutation */

// Add an observer object for the collection.
// It must conform to DIACollectionMutationDelegate protocol
// and will be refered weakly.
// Collection doesn't have a strong reference to the observer.
// You can add multiple observer from any other classes.
// Collection points observer by wrapping NSValue+unretainedObjectValue.
- (void)addDelegate:(id<DIACollectionMutationDelegate>)delegate;
// Remove the observer for the collection.
- (void)removeDelegate:(id<DIACollectionMutationDelegate>)delegate;

/** Sorting Objects */

- (void)sort;
- (void)addSortDescriptor:(NSSortDescriptor*)sortDescriptor forKey:(id<NSCopying>)key;
- (void)setSortDescriptorsWithKeyPare:(NSArray*)sortDescriptorPares;
- (void)removeSortDescriptorForKey:(id<NSCopying>)key;
- (void)removeAllSortDescriptors;

/** Filtering Objects */

- (void)addFilterPredicate:(NSPredicate*)predicate forKey:(id<NSCopying>)key;
- (void)setFilterPredicatesWithKey:(NSArray*)filterPredicatePares;
- (void)removeFilterPredicateForKey:(id<NSCopying>)key;
- (void)removeAllFilterPredicates;

/** Array Representation */

- (NSArray *)array;
- (NSArray*)actualArray;

/** OrderedSet Representation */

- (NSOrderedSet*)actualOrderedSet;
- (NSOrderedSet *)orderedSet;

/** Properties */

// Observers for the collection.
// Each observer conforms to DIACollectionMutationDelegate protocol.
@property (nonatomic, readonly) NSArray *delegates;
@property (nonatomic, readonly) NSArray *filterPredicates;
@property (nonatomic, readonly) NSArray *sortDescriptos;
@property (nonatomic, readonly) NSOrderedSet *hiddenObjects;
@property (nonatomic, copy)     NSString *sectionNameKeyPath;

@end

@protocol DIACollectionMutationDelegate <NSObject>

- (void)collectionWillChangeContent:(DIACollection*)collection;
- (void)collection:(DIACollection*)collection didAddObject:(id)object;
- (void)collection:(DIACollection*)collection didRemoveObject:(id)object;
- (void)collection:(DIACollection*)collection didHideObject:(id)object;
- (void)collection:(DIACollection*)collection didUnHideObject:(id)object;
- (void)collection:(DIACollection*)collection didMoveObject:(id)object fromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex;
- (void)collection:(DIACollection *)collection didExchangeObject:(id)obj1 withObject:(id)obj2;
- (void)collection:(DIACollection *)collection didChangeSortingWithSortDescriptros:(NSArray*)sortDescriptors;
- (void)collectioDidChangeContent:(DIACollection*)collection;

@end

