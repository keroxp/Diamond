//
//  DIACollection+NSKeyValueCoding.h
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/13.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIACollection.h"

@interface DIACollection(NSKeyValueCoding)

/* Return an ordered set containing the results of invoking -valueForKey: on each of the receiver's members. The returned ordered set might not have the same number of members as the receiver. The returned ordered set will not contain any elements corresponding to instances of -valueForKey: returning nil, nor will it contain duplicates.
 */
- (id)valueForKey:(NSString *)key NS_AVAILABLE(10_7, 5_0);

/* Invoke -setValue:forKey: on each of the receiver's members.
 */
- (void)setValue:(id)value forKey:(NSString *)key NS_AVAILABLE(10_7, 5_0);

@end
