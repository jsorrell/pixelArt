//
//  PACoordinates.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/31/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PACoordinates.h"
#import "PARectangle.h"

@implementation PACoordinates
{
    NSInteger _row;
    NSInteger _column;
}

#pragma mark - properties

- (NSInteger)row
{
    return _row;
}

- (NSInteger)column
{
    return _column;
}


#pragma mark - initialization
- (id)initWithRow:(NSInteger)row Column:(NSInteger)column
{
    if (self = [super init])
    {
        _row = row;
        _column = column;
    }
    return self;
}

+ (id)coordinatesWithRow:(NSInteger)row Column:(NSInteger)column
{
    return [[self alloc] initWithRow:row Column:column];
}

+ (id)zeroCoordinates
{
    return [self coordinatesWithRow:0 Column:0];
}


#pragma mark - shifting
- (PACoordinates *)coordsByIncrementingRowBy:(NSInteger)inc
{
    return [[self class] coordinatesWithRow:self.row+inc Column:self.column];
}
- (PACoordinates *)coordsByIncrementingColumnBy:(NSInteger)inc
{
    return [[self class] coordinatesWithRow:self.row Column:self.column+inc];
}
- (PACoordinates *)coordsByAdding:(PACoordinates *)coords
{
    return [[self class] coordinatesWithRow:self.row+coords.row Column:self.column+coords.column];
}
- (PACoordinates *)coordsBySubtracting:(PACoordinates *)coords
{
    return [[self class] coordinatesWithRow:self.row-coords.row Column:self.column-coords.column];
}

+ (NSSet *)shiftCoordinatesInSet:(NSSet *)coords By:(PACoordinates *)offset
{
    NSMutableSet *mutableCoordSet = [NSMutableSet setWithCapacity:[coords count]];
    for (PACoordinates *coord in coords)
    {
        [mutableCoordSet addObject:[PACoordinates coordinatesWithRow:coord.row + offset.row Column:coord.column + offset.column]];
    }
    return [mutableCoordSet copy];
}

+(NSSet *)negativeShiftCoordinatesInSet:(NSSet *)coords By:(PACoordinates *)offset
{
    NSMutableSet *mutableCoordSet = [NSMutableSet setWithCapacity:[coords count]];
    for (PACoordinates *coord in coords)
    {
        [mutableCoordSet addObject:[PACoordinates coordinatesWithRow:coord.row - offset.row Column:coord.column - offset.column]];
    }
    return [mutableCoordSet copy];
}


#pragma mark - other points

- (PACoordinates *)nearestPointInside:(PARectangle *)rect
{
    NSInteger row;
    NSInteger column;
    
    if (rect.origin.row > self.row)
    {
        row = rect.origin.row;
    }
    else if (self.row >= rect.origin.row + rect.size.height)
    {
        row = rect.origin.row + rect.size.height - 1;
    }
    else
    {
        row = self.row;
    }
    
    if (rect.origin.column > self.column)
    {
        column = rect.origin.column;
    }
    else if (self.column >= rect.origin.column + rect.size.width)
    {
        column = rect.origin.column + rect.size.width - 1;
    }
    else
    {
        column = self.column;
    }
    
    return [[self class] coordinatesWithRow:row Column:column];
}

- (NSUInteger)distanceToCoordinates:(PACoordinates *)coords
{
    return abs(coords.column - self.column) + abs(coords.row - self.row);
}

#

#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        PACoordinates *test = object;
        return test.row == self.row &&
        test.column == self.column;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.row * 31 + self.column;
}

- (id)copy
{
    return [[self class] coordinatesWithRow:self.row Column:self.column];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%d,%d)",self.column,self.row];
}

@end
