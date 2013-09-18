//
//  PAPixelDrawing.h
//  pixelArt
//
//  Created by Jack Sorrell on 7/29/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PARectangle.h"

@interface PAPixelDrawing : NSObject

#pragma mark - properties
@property (nonatomic,readonly) PASize *size;

#pragma mark - initialization
- (id)initWithSize:(PASize *)size Color:(UIColor *)color; //Designated Initializer
- (id)initWithSize:(PASize *)size;

#pragma mark - drawing
//undoable state needs to be forced
- (void)setColorOfSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color;

- (void)fillColorAroundSquareWithCoordinates:(PACoordinates *)coords ToColor:(UIColor *)color Undoable:(BOOL)undoable;

//can be viewed with temporaryColorAtCoordinates
- (void)startLineWithCoordinates:(PACoordinates *)coords;
- (void)temporarilySetLineEndToCoordinates:(PACoordinates *)coords Color:(UIColor *)color;
- (void)setLineEndToCoordinates:(PACoordinates *)coords Color:(UIColor *)color Undoable:(BOOL)undoable;

- (void)commitTemporaryImageUndoable:(BOOL)undoable;

#pragma mark - reading
- (void)markAsReadingCoordinates; //need to mark to see coordinates changed from point
- (void)markAsReadingTemporaryCoordinates;
- (UIColor *)colorAtCoordinates:(PACoordinates *)coords;
- (UIColor *)temporaryColorAtCoordinates:(PACoordinates *)coordinates;

#pragma mark - undoing/redoing
- (void)saveStateAsUndoable; //option to do automatically for most tools
- (void)undoToPreviousState;
- (void)redoToLastUndo;
- (NSSet *)coordinatesChangedSinceLastRead; //resets whenever read
- (NSSet *)temporaryCoordinatesChangedSinceLastRead; //resets whenever read

#pragma mark - image
- (UIImage *)createImageInRect:(PARectangle *)rect WithSize:(CGSize)size;;

- (UIImage *)createImageWithSize:(CGSize)size;

@end
