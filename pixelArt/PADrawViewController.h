//
//  PADrawViewController.h
//  pixelArt
//
//  Created by Jack Sorrell on 7/28/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "PAPixelDrawing.h"
#import "PAColorCell.h"
#import "HRColorPickerViewController.h"
#import "PADrawingView.h"
#import "PADrawingViewScroller.h"

typedef enum
{
    BRUSH_TOOL,
    LINE_TOOL,
    HAND_TOOL
} Tools;

@interface PADrawViewController : UIViewController <PADrawingViewDataSource,PADrawingViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,HRColorPickerViewControllerDelegate,UIScrollViewDelegate>
@property (nonatomic,strong) PAPixelDrawing *currentDrawing;
@property (nonatomic,weak) PADrawingView *drawingView;
@property (nonatomic,weak) IBOutlet PADrawingViewScroller *drawingViewScroller;
@property (nonatomic,strong) UIColor *currentDrawingColor;
@property (nonatomic,strong) NSIndexPath *selectedColorIndexPath;
@property (weak, nonatomic) IBOutlet UICollectionView *colorPickerCollectionView;
@property (nonatomic) BOOL drawingTemporaryImage;
@property (nonatomic) BOOL currentlyPainting;

@property (weak, nonatomic) IBOutlet UICollectionView *optionsCollectionView;

@property (weak, nonatomic) IBOutlet UICollectionView *toolsCollectionView;

@property (nonatomic) Tools currentTool;
@property (nonatomic,readonly) NSArray *toolLables;

@property (nonatomic,readonly) NSUInteger widthOfMaximumZoom;

//gesture recognizers
@property (nonatomic,strong) UILongPressGestureRecognizer *fillGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *showColorsGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *hideColorsGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *showOptionsGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *hideOptionsGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *showToolsGestureRecognizer;
@property (nonatomic,strong) UISwipeGestureRecognizer *hideToolsGestureRecognizer;
@property (nonatomic,strong) UIPinchGestureRecognizer *zoomGestureRecognizer;
@property (nonatomic,strong) UIPanGestureRecognizer *handToolGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapZoomInGestureRecognizer;
@property (nonatomic,strong) UITapGestureRecognizer *doubleTapZoomOutGestureRecognizer;




- (void)showColorPickerView;
- (void)hideColorPickerView;

- (void)showOptionsView;
- (void)hideOptionsView;

- (void)showToolsView;
- (void)hideToolsView;

- (void)undoDrawing;

- (void)goBackSaving:(BOOL)save;

- (void)hideAllToolbars;

- (void)fillColorAroundSquareAtCoordinates:(PACoordinates *)coords;

@end