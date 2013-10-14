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

#define knWillChangeContentNotification @"me.keroxp.lib.DiamonCollection:WillChangeContentNotification"
#define kDidChangeContentNotification @"me.keroxp.lib.DiamonCollection:DidChangeContentNotification"
#define kDidChangeObjectNotification @"me.keroxp.lib.DiamonCollection:DidChangeObjectNotification"
#define kDidChangeSectionNotification @"me.keroxp.lib.DiamonCollection:DidChangeSectionNotification"

typedef enum : NSUInteger{
    DIACollectionInnerStateVisible,
    DIACollectionInnerStateHidden,
    DIACollectionInnerStateFiltered,
}DIACollectionInnerState;

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
    // inner states of containig object
    NSMutableDictionary *_states;
    // NSDictionaries of pare of NSSortDescriptor and key.
    NSMutableArray *_sortDescriptors;
    // NSDictionaries of pare of NSPredicates and key.
    NSMutableArray *_filterPredicaates;
    // DeelegateChain object
    DIADelegateChain *_delegate;
}

@end

@implementation DIACollection

#pragma mark - MTLJSONSerialization

+ (NSDictionary *)JSONKeyPathsByPropertyKey
{
    return @{};
}

#pragma mark - Creating Collection

+ (instancetype)collectionWithArray:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    return [[self alloc] initWithArray:array error:error];
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
        _delegate = [DIADelegateChain new];
    }
    return self;
}

- (instancetype)initWithArray:(NSArray *)array error:(NSError *__autoreleasing *)error
{
    if (self = [self init]) {
        [_actualData addObjectsFromArray:array];
        [_visibleData addObjectsFromArray:array];
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

#pragma mark - Adding Object

- (NSUInteger)indexOfObjectToBeInsertedInSortedArray:(id)object
{
    NSUInteger idx = [_visibleData indexOfObject:object inSortedRange:NSMakeRange(0, _visibleData.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
        for (NSSortDescriptor *s in _sortDescriptors) {
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

- (BOOL)shouldFilterObject:(id)object
{
    // if inserted object matches any fileter predicate,
    // return YES
    for (NSPredicate *p in _filterPredicates) {
        if ([p evaluateWithObject:object]) {
            return YES;
        }
    }
    return NO;
}

- (void)addObject:(id)object
{
    // add objectc to actual data
    [_actualData addObject:object];
    // if have any sort description, try to insert correct position
    if ([self shouldFilterObject:object]) {
        [_filterdObjects addObject:object];
    }else{
        NSUInteger idx = [self indexOfObjectToBeInsertedInSortedArray:object];
        [_visibleData insertObject:object atIndex:idx];
    }
}

- (void)addObjectsFromArray:(NSArray *)array
{
    for (id obj in array) {
        [self addObject:obj];
    }
}

- (void)pushObject:(id)object
{
    // append to actual data
    [_actualData addObject:object];
    // filter
    if ([self shouldFilterObject:object]) {
        [_filterdObjects addObject:object];
    }else{
        [_visibleData addObject:object];
    }
}

- (void)pushObjectsFromArray:(NSArray *)array
{
    for (id obj in array) {
        [self pushObject:obj];
    }
}

- (void)insertObject:(id)object atIndex:(NSUInteger)index
{
    // insert to actual data
    [_actualData insertObject:object atIndex:index];
    // filter
    if ([self shouldFilterObject:object]) {
        [_filterdObjects addObject:object];
    }else{
        [_visibleData insertObject:object atIndex:index];
    }
}

- (void)insertObjects:(NSArray *)array atIndexes:(NSIndexSet *)indexes
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    for (i = 0; i < count; i++) {
        [self insertObject:array[i] atIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}

#pragma mark - Removing Object

- (void)removeObject:(id)object
{
    [_actualData removeObject:object];
    [_visibleData removeObject:object];
}

- (void)removeObjectsInArray:(NSArray *)array
{
    [_actualData removeObjectsInArray:array];
    [_visibleData removeObjectsInArray:array];
}

- (void)removeObjectAtIndex:(NSUInteger)index
{
    [_visibleData removeObjectAtIndex:index];
    [_actualData removeObjectAtIndex:index];
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    for (i = 0; i < count; i++) {
        [self removeObjectAtIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}

- (void)removeObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:predicate];
    [self removeObjectsAtIndexes:is];
}

- (void)removeAllObjects
{
    [_actualData removeAllObjects];
    [_visibleData removeAllObjects];
    [_filterdObjects removeAllObjects];
    [_hiddenObjects removeAllObjects];
}

#pragma mark - Moving Objects

- (void)moveObject:(id)object beforeObject:(id)beforeObject
{
    
}
- (void)moveObjectFromIndex:(NSUInteger)fromIndex toIndex:(NSUInteger)toIndex
{
    
}
- (void)exchangeObject:(id)obj1 WithObject:(id)obj2
{
    
}
- (void)exchangeObjectAtIndex:(NSUInteger)idx1 withObjectAtIndex:(NSUInteger)idx2
{
    
}

#pragma mark - Hiding Object

- (void)hideObject:(id)object
{
    NSUInteger idx = [_visibleData indexOfObject:object];
    id obj = [_visibleData objectAtIndex:idx];
    [_visibleData removeObject:obj];
    [_hiddenObjects addObject:obj];
}

- (void)hideObjectAtIndex:(NSUInteger)index
{
    [self hideObject:[_visibleData objectAtIndex:index]];
}

- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    for (i = 0; i < count; i++) {
        [self hideObjectAtIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}

- (void)hideObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:predicate];
    [self hideObjectsAtIndexes:is];
}

- (void)unHideObject:(id)object
{
    NSUInteger idx = [_hiddenObjects indexOfObject:object];
    [self unHideObjectAtIndex:idx]  ;
    if (idx != NSNotFound) {
        [_hiddenObjects removeObjectAtIndex:idx];
        [self addObject:object];
    }
}

- (void)unHideObjectAtIndex:(NSUInteger)index
{
    [self unHideObject:[_hiddenObjects objectAtIndex:index]];
}

- (void)unHideObjectsAtIndexes:(NSIndexSet*)indexes
{
    NSUInteger currentIndex = [indexes firstIndex];
    NSUInteger i, count = [indexes count];
    for (i = 0; i < count; i++) {
        [self unHideObjectAtIndex:currentIndex];
        currentIndex = [indexes indexGreaterThanIndex:currentIndex];
    }
}
                    

- (void)unHideObjectsPassingTest:(BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *is = [_visibleData indexesOfObjectsPassingTest:predicate];
    [self unHideObjectsAtIndexes:is];
}

#pragma mark - Observing Inner Mutation

- (void)addDelegate:(id<DIACollectionMutationDelegate>)delegate
{
    [_delegate addDelegate:delegate];
}

- (void)removeDelegate:(id<DIACollectionMutationDelegate>)delegate
{
    [_delegate removeDelegate:delegate];
}

#pragma mark - Sorting Objects

- (void)sort
{
    
}

- (void)addSortDescriptor:(NSSortDescriptor*)sortDescriptor forKey:(id<NSCopying>)key
{
    
}
- (void)setSortDescriptorsWithKeyPare:(NSArray*)sortDescriptorPares
{
    
}
- (void)removeSortDescriptorForKey:(id<NSCopying>)key
{
    
}
- (void)removeAllSortDescriptors
{
    
}

#pragma mark - Filtering Objects

- (void)addFilterPredicate:(NSPredicate*)predicate forKey:(id<NSCopying>)key
{
    
}
- (void)setFilterPredicatesWithKey:(NSArray*)filterPredicatePares
{
    
}
- (void)removeFilterPredicateForKey:(id<NSCopying>)key
{
    
}
- (void)removeAllFilterPredicates
{
    
}


#pragma mark - Array Representation

- (NSArray *)array
{
    return [_visibleData array];
}
- (NSArray*)actualArray
{
    return [_actualData array];
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
