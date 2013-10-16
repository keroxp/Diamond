//
//  DIACollection.m
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/10.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIACollection.h"
#import "DIADelegateChain.h"
#import "DIACollection+NSOrderedSet.h"
#import "DIACollection+NSKeyValueObserving.h"
#import "DIACollection+NSKeyValueCoding.h"

#define kDiamondFrameworkErrorDomain @"me.keroxp.lib.Diamond"

@interface DIACollection ()
{
    // actual data
    NSMutableOrderedSet *_actualData;
    // data currently visible, that is, filterd, sorted and hidden.
    NSMutableOrderedSet *_visibleData;
    // data  temporally hidden.
    NSMutableOrderedSet *_hiddenObjects;
    // data filted by predicates
    NSMutableOrderedSet *_filterdObjects;
    // DeelegateChain object
    DIADelegateChain *_delegates;
}

@end

@implementation DIACollection

#pragma mark - Creating Collection

+ (instancetype)collectionWithArray:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    return [[self alloc] initWithArray:array error:error];
}

- (instancetype)initWithArray:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    if (self = [self init]) {
        [_actualData addObjectsFromArray:array];
        [_visibleData addObjectsFromArray:array];
    }
    return self;
}

- (id)init
{
    if (self = [super init]) {
        // data store
        _actualData = [NSMutableOrderedSet new];
        _hiddenObjects = [NSMutableOrderedSet new];
        _filterdObjects = [NSMutableOrderedSet new];
        _visibleData = [NSMutableOrderedSet new];
        // filters and sort descriptions
        _sortDescriptors = [NSMutableArray new];
        _filterPredicates = [NSMutableArray new];
        // delegators chain
        _delegates = [DIADelegateChain new];
    }
    return self;
}

#pragma mark - Reflection

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    // delegate specified NSArray's method
    if ([NSOrderedSet instancesRespondToSelector:aSelector]) {
        return _visibleData;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Notification

- (void)_notifyWillChangeContent
{
    // before changen
    if ([_delegates respondsToSelector:@selector(collectionWillChangeContent:)]) {
        [(id<DIACollectionMutationDelegate>)_delegates collectionWillChangeContent:self];
    }
}

- (void)_notifySortChange
{
    // sort change
    if ([_delegates respondsToSelector:@selector(collection:didChangeSortWithSortDescriptros:)]) {
        [(id<DIACollectionMutationDelegate>)_delegates collection:self didChangeSortWithSortDescriptros:_sortDescriptors];
    }
}

- (void)_notifyChangeOfObject:(id)object
                      atIndex:(NSUInteger)index
                    forReason:(DIACollectionMutationReason)reason
                     newIndex:(NSUInteger)newIndex
{
    if ([_delegates respondsToSelector:@selector(collection:didChangeObject:atIndex:forChangeType:reason:newIndex:)]) {
        if (reason == 0) {
            // update
            [(id<DIACollectionMutationDelegate>)_delegates collection:self didChangeObject:object atIndex:DIACollectionNilIndex forChangeType:DIACollectionMutationTypeInsert reason:reason newIndex:index];
        }else if (reason < 200){
            // insert
            [(id<DIACollectionMutationDelegate>)_delegates collection:self didChangeObject:object atIndex:index forChangeType:DIACollectionMutationTypeDelete reason:reason newIndex:DIACollectionNilIndex];
        }else if (reason < 300){
            // delete
            [(id<DIACollectionMutationDelegate>)_delegates collection:self didChangeObject:object atIndex:index forChangeType:DIACollectionMutationTypeMove reason:reason newIndex:newIndex];
        }else if (reason < 400){
            // move
            [(id<DIACollectionMutationDelegate>)_delegates collection:self didChangeObject:object atIndex:index forChangeType:DIACollectionMutationTypeUpdate reason:reason newIndex:DIACollectionNilIndex];
        }
    }
}

- (void)_notifyDidChangeContent
{
    if ([_delegates respondsToSelector:@selector(collectioDidChangeContent:)]) {
        [(id<DIACollectionMutationDelegate>)_delegates collectioDidChangeContent:self];
    }
}

#pragma mark - Adding Object

- (NSUInteger)_indexOfObject:(id)object toBeInsertedInSortedSet:(NSMutableOrderedSet*)orderedSet
{
    NSUInteger idx = [orderedSet indexOfObject:object inSortedRange:NSMakeRange(0, orderedSet.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
        for (NSSortDescriptor *s in self.sortDescriptors) {
            NSComparisonResult r = [s compareObject:obj1 toObject:obj2];
            if (r != NSOrderedSame) {
                return r;
            }
        }
        // append
        return NSOrderedAscending;
    }];
    return idx;
}

- (BOOL)_shouldFilterObject:(id)object
{
    // if inserted object matches any fileter predicate,
    // return YES
    for (NSPredicate *p in self.filterPredicates) {
        if ([p evaluateWithObject:object]) {
            return YES;
        }
    }
    return NO;
}

- (void)_insertObject:(id)object atVisibleIndex:(NSUInteger)visibleIndex actualIndex:(NSUInteger)actualIndex forReason:(DIACollectionMutationReason)reason
{
    // add to actual data
    [_actualData insertObject:object atIndex:actualIndex];
    // check if should be filtered
    if ([self _shouldFilterObject:object]) {
        [_filterdObjects addObject:object];
    }else{
        // add to visible range
        [_visibleData insertObject:object atIndex:visibleIndex];
        // notify
        [self _notifyChangeOfObject:object atIndex:visibleIndex forReason:reason newIndex:NSUIntegerMax];
    }
}

- (void)addObject:(id)object
{
    [self addObjectsFromArray:@[object]];
}

- (void)addObjectsFromArray:(NSArray *)array
{
    [self _notifyWillChangeContent];
    for (id object in array) {
        // add to actual data
        NSUInteger actidx = [self _indexOfObject:object toBeInsertedInSortedSet:_actualData];
        NSUInteger visidx = [self _indexOfObject:object toBeInsertedInSortedSet:_visibleData];
        [self _insertObject:object atVisibleIndex:actidx actualIndex:visidx forReason:DIACollectionMutationReasonAdd];
    }
    [self _notifyDidChangeContent];
}

- (void)pushObject:(id)object
{
    [self pushObjectsFromArray:@[object]];
}

- (void)pushObjectsFromArray:(NSArray *)array
{
    [self _notifyWillChangeContent];
    for (id object in array) {
        NSUInteger actidx = _actualData.count-1;
        NSUInteger visidx = _visibleData.count-1;
        [self _insertObject:object atVisibleIndex:visidx actualIndex:actidx forReason:DIACollectionMutationReasonPush];
    }
    [self _notifyDidChangeContent];
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    [self insertObjects:@[object] atIndexes:[NSIndexSet indexSetWithIndex:index]];
}

- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    [self _notifyWillChangeContent];
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    for (i = 0; i < count; i++) {
        id object = array[i];
        [self _insertObject:object atVisibleIndex:currentIndex actualIndex:currentIndex forReason:DIACollectionMutationReasonInsert];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
    [self _notifyDidChangeContent];
}

#pragma mark - Removing Object

- (void)removeObject:(id)object
{
    [self removeObjectsInArray:@[object]];
}

- (void)removeObjectsInArray:(NSArray *)array
{
    [self _notifyWillChangeContent];
    for (id object in array) {
        // !notice
        // how do it if object has been hidden or filtered?
        NSUInteger idx = [_visibleData indexOfObject:object];
        [_actualData removeObject:object];
        [_visibleData removeObject:object];
        // notify
        [self _notifyChangeOfObject:object atIndex:idx forReason:DIACollectionMutationReasonRemove newIndex:NSIntegerMax];
    }
    [self _notifyDidChangeContent];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    id obj = [_visibleData objectAtIndex:index];
    [self removeObjectsInArray:@[obj]];
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *arr = [_visibleData objectsAtIndexes:indexes];
    [self removeObjectsInArray:arr];
}

- (void)removeObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:predicate];
    [self removeObjectsAtIndexes:is];
}

-(void)removeAllObjects
{
    [_filterdObjects removeAllObjects];
    [_hiddenObjects removeAllObjects];
    NSIndexSet *is = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, _actualData.count)];
    [self removeObjectsAtIndexes:is];
}

#pragma mark - Moving Objects

- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    [self _notifyWillChangeContent];
    id obj = [_visibleData objectAtIndex:fromIndex];
    [_visibleData removeObjectAtIndex:fromIndex];
    if (toIndex >= _visibleData.count) {
        [_visibleData addObject:obj];
    }else{
        [_visibleData insertObject:obj atIndex:toIndex];
    }
    [self _notifyChangeOfObject:obj atIndex:fromIndex forReason:DIACollectionMutationReasonNone newIndex:toIndex];
    [self _notifyDidChangeContent];
}

- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    [self _notifyWillChangeContent];
    id obj1 = [_visibleData objectAtIndex:idx1];
    id obj2 = [_visibleData objectAtIndex:idx2];
    [_visibleData exchangeObjectAtIndex:idx1 withObjectAtIndex:idx2];
    [self _notifyChangeOfObject:obj1 atIndex:idx1 forReason:DIACollectionMutationReasonExchange newIndex:idx2];
    [self _notifyChangeOfObject:obj2 atIndex:idx2 forReason:DIACollectionMutationReasonExchange newIndex:idx1];
    [self _notifyDidChangeContent];
}

#pragma mark - Replaceing Object

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)object
{
    [self replaceObjectsAtIndexes:[NSIndexSet indexSetWithIndex:index] withObjects:@[object]];
}

- (void)replaceObjectsAtIndexes:(NSIndexSet *)indexes withObjects:(NSArray *)objects
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    [self _notifyWillChangeContent];
    for (i = 0; i < count; i++) {
        id obj = objects[i];
        [_visibleData replaceObjectAtIndex:currentIndex withObject:obj];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
        [self _notifyChangeOfObject:obj atIndex:currentIndex forReason:DIACollectionMutationReasonReplace newIndex:DIACollectionNilIndex];
    }
    [self _notifyDidChangeContent];
}

#pragma mark - Hiding Object

- (void)hideObject:(id)object
{
    [self hideObjectsInArray:@[object]];
}

- (void)hideObjectAtIndex:(NSUInteger)index
{
    id obj = [_visibleData objectAtIndex:index];
    [self hideObjectsInArray:@[obj]];
}

- (void)hideObjectsInArray:(NSArray *)array
{
    [self _notifyWillChangeContent];
    for (id object in array) {
        NSUInteger idx = [_visibleData indexOfObject:object];
        if (idx != NSNotFound) {
            [_visibleData removeObject:object];
            [_hiddenObjects addObject:object];
            [self _notifyChangeOfObject:object atIndex:idx forReason:DIACollectionMutationReasonHidden newIndex:NSIntegerMax];
        }
    }
    [self _notifyDidChangeContent];
}

- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes
{
    NSArray *arr = [_visibleData objectsAtIndexes:indexes];
    [self hideObjectsInArray:arr];
}

- (void)hideObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:predicate];
    [self hideObjectsAtIndexes:is];
}

#pragma mark - UnHidingObjects

- (void)unHideObject:(id)object
{
    [self unHideObjectsInArray:@[object]];
}


- (void)unHideObjectsInArray:(NSArray *)array
{
    [self _notifyWillChangeContent];
    for (id object in array) {
        NSUInteger idx = [_hiddenObjects indexOfObject:object];
        if (idx != NSNotFound) {
            id obj = [_hiddenObjects objectAtIndex:idx];
            [_hiddenObjects removeObjectAtIndex:idx];
            NSUInteger visidx = [self _indexOfObject:obj toBeInsertedInSortedSet:_visibleData];
            [_visibleData insertObject:obj atIndex:visidx];
            [self _notifyChangeOfObject:obj atIndex:visidx forReason:DIACollectionMutationReasonUnHidden newIndex:NSUIntegerMax];
        }
    }
    [self _notifyDidChangeContent];
}

- (void)unHideObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_hiddenObjects indexesOfObjectsPassingTest:predicate];
    NSArray *objs = [_hiddenObjects objectsAtIndexes:is];
    [self unHideObjectsInArray:objs];
}

- (void)unhideAllObjects
{
    NSArray *arr = [_hiddenObjects array];
    [self unHideObjectsInArray:arr];
}

#pragma mark - Observing Inner Mutation

- (void)addDelegate:(id<DIACollectionMutationDelegate>)delegate
{
    [_delegates addDelegate:delegate];
}

- (void)removeDelegate:(id<DIACollectionMutationDelegate>)delegate
{
    [_delegates removeDelegate:delegate];
}

- (NSArray *)delegates
{
    return _delegates.delegates;
}

#pragma mark - Sorting Objects

- (void)sort
{
    [self _notifyWillChangeContent];
    NSComparator comparetor = ^(id obj1, id obj2){
        for (NSSortDescriptor *s in _sortDescriptors) {
            NSComparisonResult r = [s compareObject:obj1 toObject:obj2];
            if (r != NSOrderedSame) {
                return r;
            }
        }
        return NSOrderedAscending;
    };
    [_visibleData sortUsingComparator:comparetor];
    [self _notifySortChange];
    [self _notifyDidChangeContent];
}

- (void)setSortDescriptors:(NSArray *)sortDescriptors
{
    if (sortDescriptors != _sortDescriptors) {
        _sortDescriptors = sortDescriptors;
        // perform sort
        [self sort];
    }
}

#pragma mark - Filtering Objects

- (void)setFilterPredicates:(NSArray *)filterPredicates
{
    if (filterPredicates != _filterPredicates) {
        [_visibleData unionOrderedSet:_actualData];
        [_visibleData minusOrderedSet:_hiddenObjects];
        BOOL (^shouldFilter)(id) = ^(id obj){
            for (NSPredicate *p in filterPredicates) {
                if ([p evaluateWithObject:obj]) {
                    return YES;
                }
            }
            return NO;
        };
        NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
            return shouldFilter(obj);
        }];
        [self removeObjectsAtIndexes:is];
        _filterPredicates = filterPredicates;
    }
}

#pragma mark - Array Representation

- (NSArray *)array
{
    return [_visibleData array];
}

#pragma mark - OrderedSet Representation

- (NSOrderedSet *)orderedSet
{
    return [NSOrderedSet orderedSetWithOrderedSet:_visibleData];
}

- (NSOrderedSet*)actualOrderedSet
{
    return [NSOrderedSet orderedSetWithOrderedSet:_actualData];
}

- (NSOrderedSet *)filteredOrderedSet
{
    return [NSOrderedSet orderedSetWithOrderedSet:_filterdObjects];
}

- (NSOrderedSet *)hiddenOrderedSet
{
    return [NSOrderedSet orderedSetWithOrderedSet:_hiddenObjects];
}

@end
