//
//  DIADelegateChain.m
//  DiamondCollection
//
//  Created by 桜井雄介 on 2013/10/12.
//  Copyright (c) 2013年 Yusuke Sakurai. All rights reserved.
//

#import "DIADelegateChain.h"

#define maximumNumberOfDelegates 10

@interface DIADelegateChain ()
{
    __strong id   *_delegates;
    NSUInteger _numberOfDelegates;
    NSUInteger _sizeOfDelegatesArray;
    NSMutableDictionary *_pointerHashes;
}

@end

@implementation DIADelegateChain

- (id)init
{
    if (self = [super init]) {
        _pointerHashes = [NSMutableDictionary dictionaryWithCapacity:maximumNumberOfDelegates];
        // allocate memory block for delegates
        if (NULL == (_delegates = (__strong id*)calloc(maximumNumberOfDelegates, sizeof(id)))) {
            [self _raiseException:@"failed to calloc"];
            return nil;
        }
    }
    return self;
}

- (void)addDelegate:(id)delegate error:(NSError *__autoreleasing *)error
{
    // hash string for pointer of delegate object
    NSString * hash;
    // if try to add nil, raise exception
    if(delegate == nil){
        return [self _raiseError:error];
    }
    // increase memory space if needed
    if(_numberOfDelegates == _sizeOfDelegatesArray){
        if( NULL == (_delegates = (__strong id *)realloc( _delegates, (_sizeOfDelegatesArray+maximumNumberOfDelegates) * sizeof(id)))){
            return [self _raiseException:@"failed to realloc"];
        }
        _sizeOfDelegatesArray += maximumNumberOfDelegates;
    }
    // get hash string
    hash = [[NSNumber numberWithUnsignedInteger:(NSUInteger)delegate] stringValue];
    // if delegate has been already added, do nothing
    if( [_pointerHashes objectForKey:hash] != nil){
        return;
    }
    // add delegate pointer to array
    _delegates[_numberOfDelegates] = delegate;
    // register hash for delegate
    [_pointerHashes setObject: [NSNumber numberWithUnsignedInteger: _numberOfDelegates] forKey:hash];
    // increment numberOfDelegates
    _numberOfDelegates++;
}

- (void)removeDelegate:(id)delegate error:(NSError *__autoreleasing *)error
{
    
    if(delegate == nil || _numberOfDelegates == 0){
        return;
    }
    
    NSString *hash = [[NSNumber numberWithUnsignedInteger:(NSUInteger)delegate] stringValue];
    if([ _pointerHashes objectForKey:hash] == nil){
        return;
    }
    
    NSUInteger index = [[_pointerHashes objectForKey:hash] unsignedIntegerValue];
    for(NSUInteger i = index; i < _numberOfDelegates - 1; i++){
        _delegates[i] = _delegates[i+1];
    }
    
    [_pointerHashes removeObjectForKey:hash];
    _numberOfDelegates--;
}

- ( NSArray * )delegates
{
    NSUInteger i;
    NSMutableArray * delegatesArray;
    
    if( _numberOfDelegates == 0 ){
        return @[];
    }
    
    // wrap c array with NSArray
    delegatesArray = [NSMutableArray arrayWithCapacity: _numberOfDelegates];
    for(i = 0; i < _numberOfDelegates; i++ ){
        [delegatesArray addObject: _delegates[i]];
    }
    return [NSArray arrayWithArray:delegatesArray];
}

#pragma mark - Reflection

- (BOOL)respondsToSelector:(SEL)selector
{
    // when someone ask me whether to respond to some selector,
    // we delegate it to my delegates
    for(NSUInteger i = 0; i < _numberOfDelegates; i++ ){
        if([_delegates[i] respondsToSelector:selector]){
            return YES;
        }
    }
    return NO;
}

- (NSMethodSignature *)methodSignatureForSelector: (SEL)selector
{
    // check if each delegate object responds to delegate method
    // and call those methods by retuning each classe's method signature
    for(NSUInteger i = 0; i < _numberOfDelegates; i++ ){
        if([_delegates[i] respondsToSelector:selector]){
            return [[_delegates[i] class] instanceMethodSignatureForSelector:selector];
        }
    }
    return nil;
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    // chain delegate methods in order
    for(NSUInteger i = 0; i < _numberOfDelegates; i++ ){
        if([_delegates[i] respondsToSelector:[invocation selector]]){
            [invocation invokeWithTarget: _delegates[i]];
        }
    }
}

#pragma mark -

- (void)dealloc
{
    free(_delegates);
    _pointerHashes = nil;
}

- (void)_raiseError:(NSError*__autoreleasing *)error
{
    NSError *e = [NSError errorWithDomain:@"me.keroxp.lib.DiamondCollectoin" code:0 userInfo:nil];
    *error = e;
}

- (void)_raiseException:(NSString*)reason
{
    NSException *e = [NSException exceptionWithName:@"DIADelegateChainException" reason:reason userInfo:nil];
    [e raise];
}

@end
