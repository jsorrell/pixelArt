//
//  PADrawingView.h
//  pixelArt
//
//  Created by Jack Sorrell on 7/28/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PACoordinates.h"
#import "PARectangle.h"

@protocol PADrawingViewDelegate <NSObject>

@required

@optional
- (void)didTouchSquareAtCoordinates:(PACoordinates *)coords;
- (void)touchesBeganAtCoordinates:(PACoordinates *)coords;
- (void)touchesEndedAtCoordinates:(PACoordinates *)coords;
@end


@protocol PADrawingViewDataSource <NSObject>

@required
- (PASize *)drawingSize;
- (UIColor *)colorAtDrawingCoordinates:(PACoordinates *)coords;
- (CGSize)sizeOfZoomableDrawing;
@end

@interface PADrawingView : UIView

@property (nonatomic,weak) id<PADrawingViewDelegate> delegate;
@property (nonatomic,weak) id<PADrawingViewDataSource> dataSource;

@property (nonatomic) CGFloat borderSize;
@property (nonatomic,strong) UIColor *borderColor;
@property (nonatomic,readonly) CGFloat squareWidth;
@property (nonatomic,readonly) CGFloat squareHeight;

- (NSInteger)squareRowAtYLocation:(CGFloat)y;
- (NSInteger)squareColumnAtXLocation:(CGFloat)x;
- (PACoordinates *)coordinatesFromLocation:(CGPoint)location;

- (void)setNeedsDisplayAtCoordinates:(PACoordinates *)coords;
- (void)setNeedsDisplayInCoordinateSet:(NSSet *)coordSet;

@end
