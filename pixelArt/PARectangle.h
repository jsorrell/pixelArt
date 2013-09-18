//
//  PARectangle.h
//  pixelArt
//
//  Created by Jack Sorrell on 8/3/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PACoordinates.h"
#import "PASize.h"

//  The origin is the coordinates of the minimum corner of the minimum square in the rectangle.
//  The size is the number of square across an down the rectangle.
//  __ __ __ __
// |a |b |  |  |
// |__|__|__|__|
// |  |  |  |  |
// |__|__|__|__|
// |  |c |  |  |
// |__|__|__|__|
// |  |  |  |  |
// |__|__|__|__|
//
//
//  In the above graphic, a has an origin of (0,0) and a size of [1,1].
//  The rect containing a and b has an origin of (0,0) and a size of [2,1].
//  c has an origin of (1,2) and a size of [1,1].


typedef enum
{
    PARectangleVerticalScaleEven,
    PARectangleVerticalScaleTop,
    PARectangleVerticalScaleBottom
    //add more
} PARectangleVerticalScaleConst;

typedef enum
{
    PARectangleHorizontalScaleEven,
    PARectangleHorizontalScaleLeft,
    PARectangleHorizontalScaleRight
    //add more
} PARectangleHorizontalScaleConst;

@interface PARectangle : NSObject
@property (nonatomic,readonly) PACoordinates *origin;
@property (nonatomic,readonly) PASize *size;

#pragma mark - initialization
- (id)initWithOrigin:(PACoordinates *)origin size:(PASize *)size;
+ (id)rectangleWithOrigin:(PACoordinates *)origin size:(PASize *)size;

- (id)initContainingPoint:(PACoordinates *)p1 andPoint:(PACoordinates *)p2;
+ (id)rectangleContainingPoint:(PACoordinates *)p1 andPoint:(PACoordinates *)p2;

#pragma mark - inside
- (NSSet *)coordinatesInside;
- (BOOL)coordinateIsInside:(PACoordinates *)coords;
- (BOOL)rectangleIsInside:(PARectangle *)rect;
- (PARectangle *)moveIntoRectangle:(PARectangle *)largeRect; // returns nearest same size rectangle fully inside or nil if none exist;

#pragma mark - scale
- (PARectangle *)scaleByUnits:(NSInteger)units
            HorizontalOptions:(PARectangleHorizontalScaleConst)horizontalConstant
              VerticalOptions:(PARectangleVerticalScaleConst)verticalConstant;

@end
