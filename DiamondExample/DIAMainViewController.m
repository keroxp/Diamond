//
//  DIAMainViewController.m
//  Diamond
//
//  Created by 桜井雄介 on 2013/10/21.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIAMainViewController.h"
#import "Pokemon.h"

@interface DIAMainViewController ()
{
    DIACollection *_collection;
    NSMutableArray *indexPaths;
}

@end

@implementation DIAMainViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
- (IBAction)onSegmentChange:(id)sender {
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"pokedex" ofType:@"json"];
    NSString *json = [[NSString alloc] initWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray *a = [NSJSONSerialization JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    _collection = [DIACollection new];
    for (NSDictionary *d in a) {
        Pokemon *p = [[Pokemon alloc] initWithDictionary:d];
        [_collection addObject:p];
    }
    [_collection addDelegate:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _collection.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    Pokemon *p = [_collection objectAtIndex:indexPath.row];
    cell.textLabel.text = p.name;
    cell.detailTextLabel.text = [p.types componentsJoinedByString:@","];
    
    // Configure the cell...
    
    return cell;
}

#pragma mark - 

- (UITableView*)activeTableView
{
    return (self.searchDisplayController.isActive) ? self.searchDisplayController.searchResultsTableView : self.tableView;
}

- (void)collectionWillChangeContent:(DIACollection *)collection
{
    [self.activeTableView beginUpdates];
}

- (void)collection:(DIACollection *)collection didChangeObject:(id)object atIndex:(NSUInteger)index forChangeType:(DIACollectionMutationType)type reason:(DIACollectionMutationReason)reason newIndex:(NSUInteger)newIndex
{
    switch (type) {
        case DIACollectionMutationTypeDelete:{
            NSIndexPath *ip = [NSIndexPath indexPathWithIndex:index];
            [self.activeTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        case DIACollectionMutationTypeInsert:{
            NSIndexPath *ip = [NSIndexPath indexPathWithIndex:newIndex];
            [self.activeTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
            break;
            
        default:
            break;
    }
}

- (void)collection:(DIACollection *)collection didChangeSortWithSortDescriptros:(NSArray *)sortDescriptors
{
    [self.activeTableView reloadData];
}

- (void)collectioDidChangeContent:(DIACollection *)collection
{
    [self.activeTableView endUpdates];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

- (BOOL)filterWithSearchString:(NSString*)searchString scopeIndex:(NSUInteger)scopeIndex
{
    if (searchString.length > 0) {
        NSPredicate *p = nil;
        switch (scopeIndex) {
            case 0:{
                // name
                p = [NSPredicate predicateWithFormat:@"name CONTAINS %@",searchString];
                break;
            }
            case 1: {
                // types
                p = [NSPredicate predicateWithBlock:^BOOL(Pokemon *evaluatedObject, NSDictionary *bindings) {
                    if ([[evaluatedObject.types componentsJoinedByString:@""] rangeOfString:searchString].location != NSNotFound) {
                        return YES;
                    }
                    return NO;
                }];
                break;
            }
            case 2: {
                p = [NSPredicate predicateWithBlock:^BOOL(Pokemon *evaluatedObject, NSDictionary *bindings) {
                    if ([[evaluatedObject.abilities componentsJoinedByString:@""] rangeOfString:searchString].location != NSNotFound) {
                        return YES;
                    }
                    return NO;
                }];
                break;
            }
            default:
                break;
        }
        [_collection setFilterPredicates:@[p]];
    }else{
        [_collection setFilterPredicates:nil];
    }
    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    return [self filterWithSearchString:controller.searchBar.text scopeIndex:searchOption];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    return [self filterWithSearchString:searchString scopeIndex:controller.searchBar.selectedScopeButtonIndex];
}

- (void)searchDisplayController:(UISearchDisplayController *)controller willHideSearchResultsTableView:(UITableView *)tableView
{
    [_collection setFilterPredicates:nil];
}


@end
