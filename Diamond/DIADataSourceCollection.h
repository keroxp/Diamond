//
//  DIADataSourceCollection.h
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/15.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import <Diamond/Diamond.h>

@interface DIACollectionSection : NSObject

@property (nonatomic, readonly) NSString *name;
@property (nonatomic, readonly) NSString *indexTitle;
@property (nonatomic, readonly) NSRange range;

@end

@interface DIADataSourceCollection : DIACollection

@property (nonatomic, copy) NSString *sectionNameKeyPath;

// Querying object for spesified index path
// if not set sectionNameKeyPath property, always returns nil
//- (id)objectAtIndexPath:(NSIndexPath*)indexPath;
//- (NSIndexPath*)indexPathForObject:(id)object;
//- (NSArray*)sections;
//- (NSUInteger)sectionForSectionIndexTitle:(NSString*)title atIndex:(NSUInteger)sectionIndex;
//
//- (void)insertSectionWithName:(NSString*)name toIndex:(NSUInteger)index withObects:(NSArray*)objects;
//
//- (void)deleteSectionsAtIndexes:(NSIndexSet*)indexes;
//- (void)hideSectionsAtIndexes:(NSIndexSet*)indexes;

@end

@protocol DIACollectionTableViewMutationDelegate <NSObject>

//- (void)collection:(DIACollection*)collection
//   didChangeObject:(id)object
//       atIndexPath:(NSIndexPath*)indexPath
//     forChangeType:(DIACollectionMutationType)changeType
//      newIndexPath:(NSIndexPath*)newIndexPath
//         newObject:(id)newObject;
//
//- (void)collection:(DIACollection *)collection
//  didChangeSection:(NSUInteger)section
//     forChangeType:(DIACollectionMutationType)changeType;

@end
