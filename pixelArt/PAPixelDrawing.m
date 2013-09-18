//
//  PAPixelDrawing.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/29/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PAPixelDrawing.h"

typedef NSArray * DrawingData;
typedef NSMutableArray * MutableDrawingData;

@interface PAPixelDrawing()
{
    PASize *_size;
    DrawingData stateToBeSaved; //do not record current drawing as undoable until it is changed
}

@property (nonatomic,strong) MutableDrawingData dataArray;
@property (nonatomic,strong) MutableDrawingData temporaryDataArray;
@property (nonatomic,strong) NSMutableArray *undoStates; //Latest Item On End
@property (nonatomic,strong) NSMutableArray *redoStates; //Latest Item On End
@property (nonatomic,strong) PACoordinates *lineStartCoords;
@property (nonatomic,strong) NSMutableSet *coordinatesChanged;
@property (nonatomic,strong) NSMutableSet *temporaryCoordinatesChanged;
@property (nonatomic,strong) NSSet *lineCoordinates;

- (NSUInteger)indexFromCoordinates:(PACoordinates *)coords;
- (PACoordinates *)coordinatesFromIndex:(NSUInteger)index;
- (NSUInteger)incrementIndex:(NSUInteger)index ByRows:(NSInteger)rows;
- (NSUInteger)incrementIndex:(NSUInteger)index ByColumns:(NSInteger)columns;
- (NSUInteger)incrementIndex:(NSUInteger)index ByAddingCoordinates:(PACoordinates *)coords;

//return array of indices
//directly touching
- (NSSet *)squaresTouchingSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals;
- (NSSet *)squaresWithSameColorTouchingSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals;
//connected via same color
- (NSSet *)squaresColorConnectedToSquareAtCoordinates:(PACoordinates *)coords
                                            Diagonals:(BOOL)diagonals
                                                 Plus:(NSMutableSet *)colorConnected
                                                 Skip:(NSMutableSet *)skip;
//wrapper
- (NSSet *)squaresColorConnectedToSquareAtCoordinates:(PACoordinates *)coords
                                            Diagonals:(BOOL)diagonals;

- (DrawingData)layerDrawingOnTop:(DrawingData)topDrawing;
- (DrawingData)getLayerFromCoords:(NSSet *)indices Color:(UIColor *)color;

- (NSSet *) getCrossedCoordsForLineEndingAtCoords:(PACoordinates *)endCoords;

+ (NSSet *)indicesOfChangesToDrawingBetween:(DrawingData)drawing1 And:(DrawingData)drawing2;
- (NSSet *)changedCoordinatesBetweenTemporaryAnd:(DrawingData)drawing;
- (NSSet *)changedCoordinatesBetweenDrawingAnd:(DrawingData)drawing;
- (void)setTemporaryColorOfSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color;

+ (NSArray *)blankDataArrayWithPixels:(NSUInteger)pixels Color:(UIColor *)color;

@end

@implementation PAPixelDrawing

#pragma mark - properties

- (PASize *)size
{
    return _size;
}

- (NSMutableSet *)coordinatesChanged
{
    if (!_coordinatesChanged)
    {
        _coordinatesChanged = [NSMutableSet setWithCapacity:self.size.area];
    }
    return _coordinatesChanged;
}

- (NSMutableSet *)temporaryCoordinatesChanged
{
    if (!_temporaryCoordinatesChanged)
    {
        _temporaryCoordinatesChanged = [NSMutableSet setWithCapacity:self.size.area];
    }
    return _temporaryCoordinatesChanged;
}

- (NSMutableArray *)undoStates
{
    if (!_undoStates)
    {
        _undoStates = [NSMutableArray arrayWithCapacity:128];
    }
    return _undoStates;
}

- (NSMutableArray *)redoStates
{
    if (!_redoStates)
    {
        _redoStates = [NSMutableArray arrayWithCapacity:128];
    }
    return _redoStates;
}

#pragma mark - data storage

+ (NSArray *)blankDataArrayWithPixels:(NSUInteger)pixels Color:(UIColor *)color
{
    MutableDrawingData temp = [NSMutableArray arrayWithCapacity:pixels];
    for (NSUInteger i=0; i < pixels; i++)
    {
        [temp addObject:[color copy]];
    }
    return temp;
}

- (NSArray *)temporaryDataArray
{
    if (!_temporaryDataArray)
    {
        _temporaryDataArray = [self.dataArray mutableCopy];
    }
    return _temporaryDataArray;
}


- (NSUInteger)indexFromCoordinates:(PACoordinates *)coords
{
    return (coords.row * self.size.width) + coords.column;
}

- (PACoordinates *)coordinatesFromIndex:(NSUInteger)index
{
    return [PACoordinates coordinatesWithRow:index/self.size.width
                                      Column:index%self.size.height];
}

- (NSUInteger)incrementIndex:(NSUInteger)index ByRows:(NSInteger)rows
{
    PACoordinates *coordinates = [self coordinatesFromIndex:index];
    return [self indexFromCoordinates:[coordinates coordsByIncrementingRowBy:rows]];
}

- (NSUInteger)incrementIndex:(NSUInteger)index ByColumns:(NSInteger)columns
{
    PACoordinates *coordinates = [self coordinatesFromIndex:index];
    return [self indexFromCoordinates:[coordinates coordsByIncrementingColumnBy:columns]];

}

- (NSUInteger)incrementIndex:(NSUInteger)index ByAddingCoordinates:(PACoordinates *)coords
{
    return [self incrementIndex:[self incrementIndex:index ByRows:coords.row] ByColumns:coords.column];
}

#pragma mark - initialization

- (id)initWithSize:(PASize *)size Color:(UIColor *)color
{
    if (self = [super init])
    {
        _size = size;
        self.dataArray = [[[self class] blankDataArrayWithPixels:self.size.area Color:color] mutableCopy];
        [self saveStateAsUndoable];
    }
    return self;
}

- (id)initWithSize:(PASize *)size
{
    return [self initWithSize:size Color:[UIColor whiteColor]];
}

#pragma mark - drawing

- (void)setColorOfSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color
{
    NSUInteger index = [self indexFromCoordinates:coords];
    if (![color isEqual:[self.dataArray objectAtIndex:index]])
    {
        [self.coordinatesChanged addObject:coords];
        [self.dataArray replaceObjectAtIndex:index withObject:color];
        if (stateToBeSaved)
        {
            [self.undoStates addObject:stateToBeSaved];
            stateToBeSaved = nil;
        }
    }
    
}
- (void)setTemporaryColorOfSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color
{
    NSUInteger index = [self indexFromCoordinates:coords];
    if (![color isEqual:[self.temporaryDataArray objectAtIndex:index]])
    {
        [self.temporaryCoordinatesChanged addObject:coords];
        [self.temporaryDataArray replaceObjectAtIndex:index withObject:color];
    }
}

//Fill

- (NSSet *)squaresTouchingSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals
{
    NSMutableSet *touching = [NSMutableSet setWithCapacity:8];
    
    if (coords.column > 0)
        [touching addObject:[coords coordsByIncrementingColumnBy:-1]];
    if (coords.column < self.size.width-1)
        [touching addObject:[coords coordsByIncrementingColumnBy:1]];
    if (coords.row > 0)
        [touching addObject:[coords coordsByIncrementingRowBy:-1]];
    if (coords.row < self.size.height-1)
        [touching addObject:[coords coordsByIncrementingRowBy:1]];
    
    if (diagonals)
    {
        if (coords.row > 0 && coords.column > 0)
            [touching addObject:[[coords coordsByIncrementingRowBy:-1] coordsByIncrementingColumnBy:-1]];
        if (coords.row > 0 && coords.column < self.size.width-1)
            [touching addObject:[[coords coordsByIncrementingRowBy:-1] coordsByIncrementingColumnBy:1]];
        if (coords.row < self.size.height-1 && coords.column > 0)
            [touching addObject:[[coords coordsByIncrementingRowBy:1] coordsByIncrementingColumnBy:-1]];
        if (coords.row < self.size.height-1 && coords.column < self.size.width-1)
            [touching addObject:[[coords coordsByIncrementingRowBy:1] coordsByIncrementingColumnBy:1]];
    }
    return [NSSet setWithSet:touching];
}

- (NSSet *)squaresWithSameColorTouchingSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals
{
    NSSet *touching = [self squaresTouchingSquareAtCoordinates:coords Diagonals:diagonals];
    NSMutableSet *colorTouching = [NSMutableSet setWithCapacity:8];
    UIColor *color = [self colorAtCoordinates:coords];
    for (PACoordinates *squareCoords in touching)
    {
        if ([[self colorAtCoordinates:squareCoords] isEqual:color])
        {
            [colorTouching addObject:squareCoords];
        }
    }
    return [NSSet setWithSet:colorTouching];
}

//TODO:Optimize filling algorithm
- (NSSet *)squaresColorConnectedToSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals Plus:(NSMutableSet *)colorConnected Skip:(NSMutableSet *)skip
{
    //add self
    if (![skip containsObject:coords])
    {
        [colorConnected addObject:coords];
        [skip addObject:coords];
    }
    
    //get touching squares of same color
    NSSet *colorTouching = [self squaresWithSameColorTouchingSquareAtCoordinates:coords
                                                                       Diagonals:diagonals];
    
    for(PACoordinates *squareCoords in colorTouching)
    {
        if (![skip containsObject:squareCoords])
        {
            [colorConnected unionSet:[self squaresColorConnectedToSquareAtCoordinates:squareCoords
                                                                            Diagonals:diagonals
                                                                                 Plus:colorConnected
                                                                                 Skip:skip]];
        }
    }
    return colorConnected;
}

- (NSSet *)squaresColorConnectedToSquareAtCoordinates:(PACoordinates *)coords Diagonals:(BOOL)diagonals
{
    NSMutableSet *colorConnected = [NSMutableSet setWithCapacity:128];
    NSMutableSet *skip = [NSMutableSet setWithCapacity:256];
    return [self squaresColorConnectedToSquareAtCoordinates:coords
                                                  Diagonals:diagonals
                                                       Plus:colorConnected
                                                       Skip:skip];
}

- (void)fillColorAroundSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color Undoable:(BOOL)undoable
{
    NSSet *colorConnectedSquares = [self squaresColorConnectedToSquareAtCoordinates:coords Diagonals:NO];
    for (PACoordinates *squareCoords in colorConnectedSquares)
    {
        [self setColorOfSquareWithCoordinates:squareCoords ToColor:color];
    }
    if (undoable)
        [self saveStateAsUndoable];
}

- (void)startLineWithCoordinates:(PACoordinates *)coords
{
    self.lineStartCoords = coords;
    self.temporaryDataArray = [self.dataArray mutableCopy];
}

- (void)temporarilySetLineEndToCoordinates:(PACoordinates *)coords Color:(UIColor *)color
{
    NSSet *crossedCoords = [self getCrossedCoordsForLineEndingAtCoords:coords];
    
    //undo last line
    for (PACoordinates *coord in self.lineCoordinates)
    {
        [self setTemporaryColorOfSquareWithCoordinates:coord ToColor:[self colorAtCoordinates:coord]];
    }
    
    //do new line
    for (PACoordinates *coord in crossedCoords)
    {
        [self setTemporaryColorOfSquareWithCoordinates:coord ToColor:color];
    }
    
    self.lineCoordinates = crossedCoords;
}

- (void)setLineEndToCoordinates:(PACoordinates *)coords Color:(UIColor *)color Undoable:(BOOL)undoable
{
    NSSet *crossedCoords = [self getCrossedCoordsForLineEndingAtCoords:coords];
    for (PACoordinates *coord in crossedCoords)
    {
        [self setColorOfSquareWithCoordinates:coords ToColor:color];
    }
    if (undoable)
        [self saveStateAsUndoable];
}


- (void)commitTemporaryImageUndoable:(BOOL)undoable
{
    for (NSUInteger i = 0; i < self.size.area; i++)
    {
        PACoordinates *coords = [self coordinatesFromIndex:i];
        [self setColorOfSquareWithCoordinates:coords ToColor:[self temporaryColorAtCoordinates:coords]];
    }
    if (undoable)
        [self saveStateAsUndoable];
}

#pragma mark - reading

- (void)markAsReadingCoordinates
{
    [self.coordinatesChanged removeAllObjects];
}

- (void)markAsReadingTemporaryCoordinates
{
    [self.temporaryCoordinatesChanged removeAllObjects];
}

- (UIColor *)colorAtCoordinates:(PACoordinates *)coords
{
    return [self.dataArray objectAtIndex:[self indexFromCoordinates:coords]];
}

- (UIColor *)temporaryColorAtCoordinates:(PACoordinates *)coordinates
{
    return [self.temporaryDataArray objectAtIndex:[self indexFromCoordinates:coordinates]];
}

- (NSSet *)coordinatesChangedSinceLastRead
{
    return [self.coordinatesChanged copy];
}

- (NSSet *)temporaryCoordinatesChangedSinceLastRead
{
    return [self.temporaryCoordinatesChanged copy];
}

#pragma mark - undoing

- (void)saveStateAsUndoable
{
    stateToBeSaved = [self.dataArray copy];
    [self.redoStates removeAllObjects];
}

- (void)undoToPreviousState
{
    NSArray *oldState;
    NSUInteger states = [self.undoStates count];
    if (states > 0)
    {
        oldState = [self.undoStates lastObject];
        [self.redoStates addObject:[self.dataArray copy]];
        stateToBeSaved = nil;
        if (states != 1)
            [self.undoStates removeLastObject];
    }
    else
    {
        return;
    }
    
    for (NSUInteger i = 0; i < self.size.area; i++)
    {
        PACoordinates *coords = [self coordinatesFromIndex:i];
        [self setColorOfSquareWithCoordinates:coords ToColor:[oldState objectAtIndex:i]];
    }
    stateToBeSaved = [self.dataArray copy];
}

- (void)redoToLastUndo
{
    NSArray *redoState;
    if ([self.redoStates count] > 0)
    {
        redoState = [self.redoStates lastObject];
        [self.undoStates addObject:[self.dataArray copy]];
        self.dataArray = [redoState mutableCopy];
        [self.redoStates removeLastObject];
    }
}

- (NSArray *)layerDrawingOnTop:(DrawingData)topDrawing
{
    if ([topDrawing count] != self.size.area)
        return [self.dataArray copy];
    
    NSMutableArray *temporaryDataArray = [NSMutableArray arrayWithCapacity:self.size.area];
    
    for (NSUInteger i = 0; i < self.size.area; i++)
    {
        id topItem = [topDrawing objectAtIndex:i];
        if (![topItem isEqual:[NSNull null]])
        {
            [temporaryDataArray addObject:topItem];
        }
        else
        {
            [temporaryDataArray addObject:[self.dataArray objectAtIndex:i]];
        }
    }
    return [temporaryDataArray copy];
}


// TODO: fix line calculation
- (NSSet *)getCrossedCoordsForLineEndingAtCoords:(PACoordinates *)endCoords
{
    PACoordinates *startCoords = [self.lineStartCoords copy];
    NSInteger xChange, yChange;
    NSInteger horizontalMoveDirection,verticalMoveDirection;
    PACoordinates *pixelCoords;
    NSInteger error;
    
    xChange = endCoords.column - startCoords.column;
    xChange = abs(xChange);
    yChange = endCoords.row - startCoords.row;
    yChange = abs(yChange);
    
    NSMutableSet *squaresCrossed = [NSMutableSet setWithCapacity:xChange+yChange];
    
    // the horizontal direction of the line (moving left or right?)
    if (endCoords.column - startCoords.column < 0)
    {
        horizontalMoveDirection = -1;        /* Moving left */
    } else if (endCoords.column - startCoords.column > 0)
    {
        horizontalMoveDirection = 1;         /* Moving right */
    } else
    {
        horizontalMoveDirection = 0;         /* vertical line! */
    }
    /*  the vertical direction of the line (moving up or down?) */
    if (endCoords.row - startCoords.row < 0)
    {
        verticalMoveDirection = -1;       /* Moving up */
    } else if (endCoords.row - startCoords.row > 0)
    {
        verticalMoveDirection = 1;        /* Moving down */
    } else
    {
        verticalMoveDirection = 0;          /* horizontal line! */
    }
    
    /* Initialize the error term */
    error = 0;
    /* Calculate where the first pixel will be placed */
    pixelCoords = startCoords;
    /* the drawing loop */
    if (xChange > yChange)
    {
        /* Line is more horizontal than vertical (x>y) */
        for (NSInteger i = 0; i <= xChange; i++)
        {
            // Add this pixel
            [squaresCrossed addObject:[pixelCoords copy]];
            // Move the pixelOffset 1 pixel left or right. (x)
            pixelCoords = [pixelCoords coordsByIncrementingColumnBy:horizontalMoveDirection];
            // Time to move pixelOffset up or down? (y)
            error += yChange;
            if (error > xChange)
            {
                /* Yes. Reset the error term */
                error -= xChange;
                /* And move the pixelOffset 1 pixel up or down */
                pixelCoords = [pixelCoords coordsByIncrementingRowBy:verticalMoveDirection];
            }
        }
    } else
    {
        // Line is more vertical than horizontal: (y>x).
        for (NSInteger i = 0; i <= yChange; i++)
        {
            // Draw this pixel
            [squaresCrossed addObject:[pixelCoords copy]];
            // Move pixelOffset up or down. (y)
            pixelCoords = [pixelCoords coordsByIncrementingRowBy:verticalMoveDirection];
            // Time to move pixelOffset left or right? (x)
            error += xChange;
            if (error > yChange)
            {
                /* Yes. Reset the error term */
                error -= yChange;
                /* And move the pixelOffset 1 pixel left or right */
                pixelCoords = [pixelCoords coordsByIncrementingColumnBy:horizontalMoveDirection];
            }
        }
    }
    return [squaresCrossed copy];
}

- (NSArray *)getLayerFromCoords:(NSSet *)indices Color:(UIColor *)color
{
    MutableDrawingData layer = [NSMutableArray arrayWithCapacity:self.size.area];
    for (NSUInteger index = 0; index < self.size.area; index++)
    {
        if ([indices containsObject:[self coordinatesFromIndex:index]])
        {
            [layer addObject:color];
        }
        else
        {
            [layer addObject:[NSNull null]];
        }
    }
    return [layer copy];
}

+ (NSSet *)indicesOfChangesToDrawingBetween:(DrawingData)drawing1 And:(DrawingData)drawing2
{
    if ([drawing1 count] != [drawing2 count])
        return nil;
    NSMutableSet *changes = [NSMutableSet setWithCapacity:[drawing1 count]];

    for (NSInteger i = 0; i < [drawing1 count]; i++)
    {
        if (!([drawing1 objectAtIndex:i] != [drawing2 objectAtIndex:i]))
        {
            [changes addObject:[NSNumber numberWithInteger:i]];
        }
    }
    return [changes copy];
}

- (NSSet *)changedCoordinatesBetweenTemporaryAnd:(DrawingData)drawing
{
    if (self.size.area != [drawing count])
        return nil;
    NSSet *indices = [[self class] indicesOfChangesToDrawingBetween:self.temporaryDataArray And:drawing];
    NSMutableSet *changed = [NSMutableSet setWithCapacity:[indices count]];
    NSUInteger index;
    for (NSNumber *i in indices)
    {
        index = [i integerValue];
        [changed addObject:[self coordinatesFromIndex:index]];
    }
    return [changed copy];
}

- (NSSet *)changedCoordinatesBetweenDrawingAnd:(DrawingData)drawing
{
    if (self.size.area != [drawing count])
        return nil;
    NSSet *indices = [[self class] indicesOfChangesToDrawingBetween:self.dataArray And:drawing];
    NSMutableSet *changed = [NSMutableSet setWithCapacity:[indices count]];
    NSUInteger index;
    for (NSNumber *i in indices)
    {
        index = [i integerValue];
        [changed addObject:[self coordinatesFromIndex:index]];
    }
    return [changed copy];
}

#pragma mark - bitmap image

- (UIImage *)createImageInRect:(PARectangle *)rect WithSize:(CGSize)size
{
    CGFloat squareWidth = size.width/(CGFloat)rect.size.width;
    CGFloat squareHeight = size.height/(CGFloat)rect.size.height;
    
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    for (PACoordinates *coord in [rect coordinatesInside])
    {
        CGContextSetFillColorWithColor(context, [self colorAtCoordinates:coord].CGColor);
        CGContextFillRect(context, CGRectMake((CGFloat)coord.column*squareWidth, (CGFloat)coord.row*squareHeight, squareWidth, squareHeight));
    }
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage *)createImageWithSize:(CGSize)size
{
    return [self createImageInRect:[PARectangle rectangleWithOrigin:[PACoordinates zeroCoordinates]
                                                               size:self.size]
                          WithSize:size];
}
















@end
