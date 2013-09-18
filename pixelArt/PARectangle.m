//
//  PARectangle.m
//  pixelArt
//
//  Created by Jack Sorrell on 8/3/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PARectangle.h"

@implementation PARectangle
{
    PACoordinates *_origin;
    PASize *_size;
}

- (PACoordinates *)origin
{
    return _origin;
}

- (PASize *)size
{
    return _size;
}

#pragma mark - initialization

- (id)initWithOrigin:(PACoordinates *)origin size:(PASize *)size
{
    if (self = [super init])
    {
        _origin = origin;
        _size = size;
    }
    return self;
}

+ (id)rectangleWithOrigin:(PACoordinates *)origin size:(PASize *)size
{
    return [[self alloc] initWithOrigin:origin size:size];
}

- (id)initContainingPoint:(PACoordinates *)p1 andPoint:(PACoordinates *)p2
{
    NSInteger x1;
    NSInteger x2;
    NSInteger y1;
    NSInteger y2;
    
    x1 = MIN(p1.column,p2.column);
    x2 = MAX(p1.column,p2.column);
    y1 = MIN(p1.row, p2.row);
    y2 = MAX(p1.row, p2.row);
    
    return [self initWithOrigin:[PACoordinates coordinatesWithRow:y1 Column:x1]
                           size:[PASize sizeWithWidth:x2-x1+1 Height:y2-y1+1]];
    
}

+ (id)rectangleContainingPoint:(PACoordinates *)p1 andPoint:(PACoordinates *)p2
{
    return [[self alloc] initContainingPoint:p1 andPoint:p2];
}

#pragma mark - inside
- (NSSet *)coordinatesInside
{
    NSMutableSet *inside = [NSMutableSet setWithCapacity:self.size.area];
    for (NSInteger row = self.origin.row; row < self.origin.row + self.size.height; row++)
        for (NSInteger column = self.origin.column; column < self.origin.column + self.size.width; column++)
        {
            [inside addObject:[PACoordinates coordinatesWithRow:row Column:column]];
        }
    return [inside copy];
}

- (BOOL)coordinateIsInside:(PACoordinates *)coords
{
    return self.origin.row <= coords.row && self.origin.column <= coords.column &&
    coords.row < self.origin.row + self.size.height && coords.column < self.origin.column + self.size.width;
}

- (BOOL)rectangleIsInside:(PARectangle *)rect
{
    return self.origin.row <= rect.origin.row && self.origin.column <= rect.origin.column &&
    rect.origin.row + rect.size.height <= self.origin.row + self.size.height &&
    rect.origin.column + rect.size.width <= self.origin.column + self.size.width;
}

- (PARectangle *)moveIntoRectangle:(PARectangle *)largeRect
{
    NSInteger originRow = self.origin.row;
    NSInteger originColumn = self.origin.column;
    
    if (originRow < largeRect.origin.row)
        originRow = largeRect.origin.row;
    else if (originRow + self.size.height > largeRect.origin.row + largeRect.size.height)
        originRow = largeRect.origin.row + largeRect.size.height - self.size.height;
    
    if (originColumn < largeRect.origin.column)
        originColumn = largeRect.origin.column;
    else if (originColumn + self.size.width > largeRect.origin.column + largeRect.size.width)
        originColumn = largeRect.origin.column + largeRect.size.width - self.size.width;
    
    return [PARectangle rectangleWithOrigin:[PACoordinates coordinatesWithRow:originColumn Column:originColumn] size:self.size];
}

#pragma mark - scale
- (PARectangle *)scaleByUnits:(NSInteger)units HorizontalOptions:(PARectangleHorizontalScaleConst)horizontalConstant VerticalOptions:(PARectangleVerticalScaleConst)verticalConstant
{
    NSInteger originColumn = self.origin.column;
    NSInteger originRow = self.origin.row;
    
    NSUInteger width = self.size.width + units;
    NSUInteger height = self.size.height + units;
    
    if (units > 0)
    {
        if (NSUIntegerMax - units < self.size.width)
            width = NSUIntegerMax;
        if (NSUIntegerMax - units < self.size.height)
            height = NSUIntegerMax;
    }
    else if (units < 0)
    {
        if (-units > self.size.width)
            width = 0;
        else
        if (-units > self.size.height)
            height = 0;
    }
    else return self;
    
    
    switch (horizontalConstant)
    {
        case PARectangleHorizontalScaleEven:
            originColumn += units/2;
            break;
        case PARectangleHorizontalScaleLeft:
            originColumn += units;
            break;
        case PARectangleHorizontalScaleRight:
            break;
        default:
            break;
    }
    
    switch (verticalConstant)
    {
        case PARectangleVerticalScaleEven:
            originRow += units/2;
            break;
        case PARectangleVerticalScaleBottom:
            break;
        case PARectangleVerticalScaleTop:
            originRow += units;
            break;
            
        default:
            break;
    }
    
    return [PARectangle rectangleWithOrigin:[PACoordinates coordinatesWithRow:originRow Column:originColumn]
                                       size:[PASize sizeWithHeight:height HeightWidthRatio:width]];
}




#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        PARectangle *test = object;
        return [test.origin isEqual:self.origin] &&
        [test.size isEqual:self.size];
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    return [self.origin hash] * 31 + [self.size hash];
}

- (id)copy
{
    return [[self class] rectangleWithOrigin:self.origin size:self.size];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"{%@,%@}",self.origin,self.size];
}












@end
