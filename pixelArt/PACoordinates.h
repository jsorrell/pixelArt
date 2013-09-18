//
//  PACoordinates.h
//  pixelArt
//
//  Created by Jack Sorrell on 7/31/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PARectangle;

@interface PACoordinates : NSObject

#pragma mark - properties
@property (nonatomic,readonly) NSInteger row;
@property (nonatomic,readonly) NSInteger column;


#pragma mark - initialization
- (id)initWithRow:(NSInteger)row Column:(NSInteger)column;
+ (id)coordinatesWithRow:(NSInteger)row Column:(NSInteger)column;
+ (id)zeroCoordinates;

#pragma mark - shifting
- (PACoordinates *)coordsByIncrementingRowBy:(NSInteger)inc;
- (PACoordinates *)coordsByIncrementingColumnBy:(NSInteger)inc;
- (PACoordinates *)coordsByAdding:(PACoordinates *)coords;
- (PACoordinates *)coordsBySubtracting:(PACoordinates *)coords;
+ (NSSet *)shiftCoordinatesInSet:(NSSet *)coords By:(PACoordinates *)offset;
+ (NSSet *)negativeShiftCoordinatesInSet:(NSSet *)coords By:(PACoordinates *)offset;


#pragma mark - other points
- (PACoordinates *)nearestPointInside:(PARectangle *)rect;
- (NSUInteger)distanceToCoordinates:(PACoordinates *)coords;


@end
