//
//  PADrawingView.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/28/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PADrawingView.h"

@interface PADrawingView()
- (NSSet *)coordinatesInRect:(CGRect)rect;
- (CGPoint)getLocationForSquareAtCoordinates:(PACoordinates *)coordinates;
- (CGRect)getRectForSquareAtCoordinates:(PACoordinates *)coords;
@end

@implementation PADrawingView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        
    }
    return self;
}

- (CGFloat)borderSize
{
    if (_borderSize == 0.0f)
    {
        _borderSize = (self.dataSource.sizeOfZoomableDrawing.width/(CGFloat)self.dataSource.drawingSize.width)/20.0f;
    }
    return _borderSize;
}

- (UIColor *)borderColor
{
    if (!_borderColor)
    {
        _borderColor = [UIColor grayColor];
    }
    return _borderColor;
}

- (void)drawRect:(CGRect)rect
{
    NSSet *coords = [self coordinatesInRect:rect];
    for (PACoordinates *coord in coords)
    {
        UIColor *color = [self.dataSource colorAtDrawingCoordinates:coord];
        //get the context
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        //set the line width
        CGContextSetLineWidth(context, self.borderSize);
        //and stroke color
        CGContextSetStrokeColorWithColor(context, self.borderColor.CGColor);
        //and fill color
        CGContextSetFillColorWithColor(context, color.CGColor);
        
        //make and add the rectangle to path
        CGRect squareRect =
        CGRectMake([self squareWidth] * (CGFloat)coord.column, [self squareHeight] * (CGFloat)coord.row, [self squareWidth], [self squareHeight]);
        CGRect smallerRect = CGRectInset(squareRect, self.borderSize/2.0f, self.borderSize/2.0f);
        CGContextAddRect(context, squareRect);
        
        //stroke and fill the path
        CGContextStrokePath(context);
        CGContextFillRect(context, smallerRect);
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] == 1)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self];
        PACoordinates *coords = [self coordinatesFromLocation:location];
        if ([self.delegate respondsToSelector:@selector(touchesBeganAtCoordinates:)])
            [self.delegate touchesBeganAtCoordinates:coords];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] == 1)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self];
        PACoordinates *coords = [self coordinatesFromLocation:location];
        CGPoint previousLocation = [touch previousLocationInView:self];
        PACoordinates *previousCoords = [self coordinatesFromLocation:previousLocation];
        if (!([coords isEqual:previousCoords]))
        {
            [self.delegate didTouchSquareAtCoordinates:previousCoords];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([[event allTouches] count] == 1)
    {
        UITouch *touch = [[event allTouches] anyObject];
        CGPoint location = [touch locationInView:self];
        PACoordinates *coords = [self coordinatesFromLocation:location];
        [self.delegate didTouchSquareAtCoordinates:coords];
        if ([self.delegate respondsToSelector:@selector(touchesEndedAtCoordinates:)])
            [self.delegate touchesEndedAtCoordinates:coords];
    }
}


- (CGFloat)squareWidth
{
    return self.dataSource.sizeOfZoomableDrawing.width/(CGFloat)[self.dataSource drawingSize].width;
}

- (CGFloat)squareHeight
{
    return self.dataSource.sizeOfZoomableDrawing.height/(CGFloat)[self.dataSource drawingSize].height;
}

- (NSInteger)squareRowAtYLocation:(CGFloat)y
{
    return (NSInteger)(y/self.squareHeight);
}

- (NSInteger)squareColumnAtXLocation:(CGFloat)x
{
    return (NSInteger)(x/self.squareWidth);
}

- (CGPoint)getLocationForSquareAtCoordinates:(PACoordinates *)coords
{
    return CGPointMake(((CGFloat)coords.column)*self.squareWidth,((CGFloat)coords.row)*self.squareHeight);
}

- (CGRect)getRectForSquareAtCoordinates:(PACoordinates *)coords
{
    CGPoint location = [self getLocationForSquareAtCoordinates:coords];
    CGFloat x = location.x;
    CGFloat y = location.y;
    return CGRectMake(x, y, self.squareWidth, self.squareHeight);
}

- (void)setNeedsDisplayAtCoordinates:(PACoordinates *)coords
{
    [self setNeedsDisplayInRect:[self getRectForSquareAtCoordinates:coords]];
}

- (void)setNeedsDisplayInCoordinateSet:(NSSet *)coordSet
{
    for (PACoordinates *coords in coordSet)
    {
        [self setNeedsDisplayAtCoordinates:coords];
    }
}

- (PACoordinates *)coordinatesFromLocation:(CGPoint)location
{
    return [[PACoordinates coordinatesWithRow:[self squareRowAtYLocation:location.y]
                                      Column:[self squareColumnAtXLocation:location.x]]
            nearestPointInside:[PARectangle rectangleWithOrigin:[PACoordinates zeroCoordinates]
                                                           size:self.dataSource.drawingSize]];
}

- (NSSet *)coordinatesInRect:(CGRect)rect
{
    return [[PARectangle rectangleContainingPoint:[self coordinatesFromLocation:rect.origin]
                                         andPoint:[self coordinatesFromLocation:CGPointMake(rect.origin.x + rect.size.width - self.squareWidth/2.0, rect.origin.y + rect.size.height - self.squareHeight/2.0)]] coordinatesInside];
}

@end
