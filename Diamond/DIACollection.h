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

// remove object from visible range by using removeObjectAtIndex: with isEqual: method.
// thus, we'll remove at most one object.
// we will not remove second or thrid object with internal equality.
- (void)removeObject:(id)object;
// remove object at specified index
- (void)removeObjectAtIndex:(NSUInteger)index;
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
- (void)hideObjectAtIndex:(NSUInteger)index;
- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)hideObjectsPassingTest:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))predicate;

/** Unhiding Objects */

- (void)unHideObject:(id)object;
- (void)unHideObjectAtIndex:(NSUInteger)index;
- (void)unHideObjectsAtIndexes:(NSIndexSet*)indexes;
- (void)unHideObjectsPassingTest:(BOOL(^)(id obj, NSUInteger idx, BOOL *stop))predicate;

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
- (NSArray *)actualArray;

/** OrderedSet Representation */

- (NSOrderedSet *)filteredOrderedSet;
- (NSOrderedSet *)hiddenOrderedSet;
- (NSOrderedSet *)actualOrderedSet;
- (NSOrderedSet *)orderedSet;

/** Properties */

// Observers for the collection.
// Each observer conforms to DIACollectionMutationDelegate protocol.
@property (nonatomic, readonly) NSArray *delegates;
@property (nonatomic, readonly) NSArray *filterPredicates;
@property (nonatomic, readonly) NSArray *sortDescriptors;
@property (nonatomic, copy)     NSString *sectionNameKeyPath;

@end

typedef enum : NSUInteger{
    DIACollectionMutationTypeInsert,
    DIACollectionMutationTypeDelete,
    DIACollectionMutationTypeMove,
    DIACollectionMutationTypeExchange,
    DIACollectionMutationTypeReplace,
    DIACollectionMutationTypeUpdate
}DIACollectionMutationType;

@protocol DIACollectionMutationDelegate <NSObject>

- (void)collectionWillChangeContent:(DIACollection*)collection;
- (void)collection:(DIACollection*)collection didChagneObject:(id)object atIndex:(NSUInteger)index forChangeType:(DIACollectionMutationType)changeType newIndex:(NSUInteger)newIndex newObject:(id)newObject;
- (void)collection:(DIACollection *)collection didChangeSortingWithSortDescriptros:(NSArray*)sortDescriptors;
- (void)collectioDidChangeContent:(DIACollection*)collection;

@end

@interface DIACollection (NSOrderedSetProtocol)
<NSCopying, NSSecureCoding, NSFastEnumeration>

@end

@interface DIACollectionSection : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSRange range;

@end

@interface DIACollection (UITableViewDataSource)

@property (nonatomic, copy) NSString *sectionNameKeyPath;

// Querying object for spesified index path
// if not set sectionNameKeyPath property, always returns nil
- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
- (NSIndexPath*)indexPathForObject:(id)object;
- (NSArray*)sections;
- (NSUInteger)sectionForSectionIndexTitle:(NSString*)title atIndex:(NSUInteger)sectionIndex;

- (void)insertSectionWithName:(NSString*)name toIndex:(NSUInteger)index withObects:(NSArray*)objects;

- (void)deleteSectionsAtIndexes:(NSIndexSet*)indexes;
- (void)hideSectionsAtIndexes:(NSIndexSet*)indexes;

@end

@protocol DIACollectionTableViewMutationDelegate <NSObject>

- (void)collection:(DIACollection*)collection
   didChangeObject:(id)object
       atIndexPath:(NSIndexPath*)indexPath
     forChangeType:(DIACollectionMutationType)changeType
      newIndexPath:(NSIndexPath*)newIndexPath
         newObject:(id)newObject;

- (void)collection:(DIACollection *)collection
  didChangeSection:(NSUInteger)section
     forChangeType:(DIACollectionMutationType)changeType;

@end