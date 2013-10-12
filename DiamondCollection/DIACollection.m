//
//  DIACollection.m
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/10.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIACollection.h"

#define kDiamondFrameworkErrorDomain @"me.keroxp.lib.Diamond"

#define knWillChangeContentNotification @"me.keroxp.lib.DiamonCollection:WillChangeContentNotification"
#define kDidChangeContentNotification @"me.keroxp.lib.DiamonCollection:DidChangeContentNotification"
#define kDidChangeObjectNotification @"me.keroxp.lib.DiamonCollection:DidChangeObjectNotification"
#define kDidChangeSectionNotification @"me.keroxp.lib.DiamonCollection:DidChangeSectionNotification"

@interface DIACollection ()
{
    // actual data
    NSMutableArray *_actualData;
    // data  temporally hidden.
    NSMutableArray *_hiddenData;
    // data currently visible, that is, filterd, sorted and hidden.
    NSMutableArray *_visibleData;
    // NSDictionaries of pare of NSSortDescriptor and key.
    NSMutableArray *_sortDescriptorsPare;
    // NSDictionaries of pare of NSPredicates and key.
    NSMutableArray *_filterPredicatesPare;
    // Observers for inner mutation. Indeed, an array of NSValue.
    NSMutableArray *_observers;
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
        _actualData = @[].mutableCopy;
        _hiddenData = @[].mutableCopy;
        _visibleData = @[].mutableCopy;
        _sortDescriptorsPare = @[].mutableCopy;
        _filterPredicatesPare = @[].mutableCopy;
        _observers = @[].mutableCopy;
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

#pragma mark - Meta Programming

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    // if missing method is a part of NSArray's instance,
    // we delegate that selector to our _visibleData
    if ([NSArray instancesRespondToSelector:aSelector]) {
        return _visibleData;
    }
    return [super forwardingTargetForSelector:aSelector];
}

#pragma mark - Adding Object

- (void)addObject:(id)object
{
    // add objectc to actual data
    [_actualData addObject:object];
    
    // if have any sort description, try to insert correct position
    if (_sortDescriptos.count > 0) {
        NSUInteger idx = [_visibleData indexOfObject:object inSortedRange:NSMakeRange(0, _visibleData.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2) {
            for (NSSortDescriptor *s in _sortDescriptos) {
                NSComparisonResult r = [s compareObject:obj1 toObject:obj2];
                if (r != NSOrderedSame) {
                    return r;
                }
            }
            return NSOrderedSame;
        }];
        [_visibleData insertObject:object atIndex:idx];
    }else{
        // else add to the last
        [_visibleData addObject:object];
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
    [_actualData addObject:object];
    [_visibleData addObject:object];
}

- (void)pushObjectsFromArray:(NSArray *)array
{
    for (id obj in array) {
        [self pushObject:obj];
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
    for (id obj in array) {
        [self removeObject:obj];
    }
}

- (void)removeObjectsAtIndexes:(NSIndexSet*)indexes
{
    
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
    
}
- (void)hideObjectAtIndex:(NSUInteger)index
{
    
}
- (void)hideObjectsAtIndexes:(NSIndexSet*)indexes
{
    
}
- (void)unHideObject:(id)object
{
    
}
- (void)unHideObjectAtIndex:(NSUInteger)index
{
    
}
- (void)unHideObjectsAtIndexes:(NSIndexSet*)indexes
{
    
}

#pragma mark - Observing Inner Mutation

- (void)addObserver:(id<DIACollectionMutationDelegate>)observer
{
    
}
- (void)removeObserver:(id<DIACollectionMutationDelegate>)observer
{
    
}

#pragma mark - Sorting Objects

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

#pragma mark - Counting Objects

- (NSUInteger)actualCount
{
    return _actualData.count;
}

#pragma mark - Array Representation

- (NSArray *)array
{
    return [NSArray arrayWithArray:_visibleData];
}
- (NSArray*)actualArray
{
    return [NSArray arrayWithArray:_actualData];
}

#pragma mark - OrderedSet Representation

- (NSOrderedSet *)orderedSet
{
    return [NSOrderedSet orderedSetWithArray:_visibleData];
}

- (NSOrderedSet*)actualOrderedSet
{
    return [NSOrderedSet orderedSetWithArray:_actualData];
}

#pragma mark - NSCopying

- (id)copyWithZone:(NSZone *)zone
{
    return nil;
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return nil;
}

-  (void)encodeWithCoder:(NSCoder *)aCoder
{
    
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(__unsafe_unretained id [])buffer count:(NSUInteger)len
{
    return 0;
}

@end
