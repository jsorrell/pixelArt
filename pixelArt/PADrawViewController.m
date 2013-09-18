//
//  PADrawViewController.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/28/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PADrawViewController.h"

typedef enum
{
    NO_TOOLBAR,
    COLOR_PICKER_TOOLBAR,
    OPTIONS_TOOLBAR,
    DRAWING_TOOLS_TOOLBAR
} TOOLBAR_SHOWING;

@interface PADrawViewController ()
{
    TOOLBAR_SHOWING _toolbarShowing;
}
@property (nonatomic,readonly) NSArray *rainbowColors;
@property (nonatomic,readonly) NSArray *grayscaleColors;
@property (nonatomic,strong) NSMutableArray *recentColors;

@property (nonatomic) TOOLBAR_SHOWING toolbarShowing;


//swipe views
@property (nonatomic,weak) UIView *bottomSwipeView;
@property (nonatomic,weak) UIView *leftSwipeView;
@property (nonatomic,weak) UIView *topSwipeView;


- (void)addRecentColor:(UIColor *)color;
- (void)removeToolbarShowGestureRecognizers;
- (void)addToolbarShowGestureRecognizers;

- (void)fillGestureRecognized:(UILongPressGestureRecognizer *)recognizer;

@end

@implementation PADrawViewController

#pragma mark - initiation

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - view actions
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.drawingView.dataSource = self;
    self.drawingView.delegate = self;
    self.navigationItem.hidesBackButton = YES;


    PADrawingView *drawingView = [[PADrawingView alloc] initWithFrame:(CGRect){CGPointZero, self.sizeOfZoomableDrawing}];
    drawingView.dataSource = self;
    drawingView.delegate = self;
    self.drawingView = drawingView;
    
    //Scroll view setup
    //FIXME: guessing values in scroll view setup
    self.drawingViewScroller.contentOffset = CGPointZero;
    self.drawingViewScroller.contentSize = self.sizeOfZoomableDrawing;
    
    self.drawingViewScroller.minimumZoomScale = 1.0;
    self.drawingViewScroller.maximumZoomScale = 5.0;
    self.drawingViewScroller.zoomScale = 1.0;
    
    self.drawingViewScroller.panGestureRecognizer.minimumNumberOfTouches = 3;
    self.drawingViewScroller.panGestureRecognizer.maximumNumberOfTouches = 3;
    
    self.drawingViewScroller.scrollEnabled = YES;
    
    [self.drawingViewScroller addSubview:drawingView];
    
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.showColorsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.showColorsGestureRecognizer];
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.showOptionsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.showOptionsGestureRecognizer];
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.showToolsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.showToolsGestureRecognizer];
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.hideColorsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.hideColorsGestureRecognizer];
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.hideOptionsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.hideOptionsGestureRecognizer];
    [self.drawingViewScroller.panGestureRecognizer requireGestureRecognizerToFail:self.hideToolsGestureRecognizer];
    [self.drawingViewScroller.pinchGestureRecognizer requireGestureRecognizerToFail:self.hideToolsGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.drawingView addGestureRecognizer:self.fillGestureRecognizer];
    [self addToolbarShowGestureRecognizers];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self hideAllToolbars];
}

- (void)viewDidDisappear:(BOOL)animated
{
    
}

#pragma mark - properties

- (PAPixelDrawing *)currentDrawing
{
    if (!_currentDrawing)
    {
        _currentDrawing = [[PAPixelDrawing alloc] initWithSize:[PASize sizeWithWidth:20 Height:30]];
    }
    return _currentDrawing;
}

- (NSArray *)toolLables
{
    return @[@"Brush Tool",@"Line Tool",@"Hand Tool"];
}

- (NSUInteger)widthOfMaximumZoom
{
    return 4;
}

#pragma mark - color picker

- (NSIndexPath *)selectedColorIndexPath
{
    if (!_selectedColorIndexPath)
    {
        _selectedColorIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    }
    return _selectedColorIndexPath;
}

- (UIColor *)currentDrawingColor
{
    if (!_currentDrawingColor)
    {
        _currentDrawingColor = [UIColor redColor];
    }
    return _currentDrawingColor;
}

- (void)addRecentColor:(UIColor *)color
{
    [self.recentColors insertObject:color atIndex:0];
    if ([self.recentColors count] > 7)
    {
        [self.recentColors removeLastObject];
    }
    [self.colorPickerCollectionView reloadData];
}

- (NSArray *)rainbowColors
{
    return @[[UIColor redColor],
             [UIColor orangeColor],
             [UIColor yellowColor],
             [UIColor greenColor],
             [UIColor blueColor],
             [UIColor purpleColor],
             [UIColor magentaColor]];
}

- (NSArray *)grayscaleColors
{
    return @[[UIColor blackColor],
             [UIColor colorWithHue:0 saturation:0 brightness:0.25 alpha:1],
             [UIColor colorWithHue:0 saturation:0 brightness:0.4 alpha:1],
             [UIColor colorWithHue:0 saturation:0 brightness:0.6 alpha:1],
             [UIColor colorWithHue:0 saturation:0 brightness:0.75 alpha:1],
             [UIColor colorWithHue:0 saturation:0 brightness:0.9 alpha:1],
             [UIColor whiteColor]];
}

- (NSMutableArray *)recentColors
{
    int numberOfRecentColors = 7;
    if (!_recentColors)
    {
        _recentColors = [NSMutableArray arrayWithCapacity:7];
        for (int i=0; i<numberOfRecentColors; i++)
        {
            [_recentColors addObject:[UIColor whiteColor]];
        }
    }
    return _recentColors;
}

#pragma mark - drawing actions

- (void)fillColorAroundSquareAtCoordinates:(PACoordinates *)coords
{
    [self.currentDrawing fillColorAroundSquareWithCoordinates:coords ToColor:self.currentDrawingColor Undoable:YES];
    [self.drawingView setNeedsDisplayInCoordinateSet:[self.currentDrawing coordinatesChangedSinceLastRead]];
}

- (void)undoDrawing
{
    [self.currentDrawing undoToPreviousState];
    [self.drawingView setNeedsDisplayInCoordinateSet:[self.currentDrawing coordinatesChangedSinceLastRead]];
    [self.currentDrawing markAsReadingCoordinates];
}


#pragma mark - PADrawingViewDelegate

- (void)didTouchSquareAtCoordinates:(PACoordinates *)coords
{
    switch (self.currentTool)
    {
        case BRUSH_TOOL:
        {
            self.currentlyPainting = YES;
            [self.currentDrawing setColorOfSquareWithCoordinates:coords ToColor:self.currentDrawingColor];
            [(PADrawingView *)self.drawingView setNeedsDisplayAtCoordinates:coords];
            break;
        }
        case LINE_TOOL:
        {
            if (!self.drawingTemporaryImage)
            {
                self.drawingTemporaryImage = YES;
                [self.currentDrawing startLineWithCoordinates:coords];
            }
            [self.currentDrawing temporarilySetLineEndToCoordinates:coords Color:self.currentDrawingColor];
            NSSet *changedCoordinates = [self.currentDrawing temporaryCoordinatesChangedSinceLastRead];
            [self.drawingView setNeedsDisplayInCoordinateSet:changedCoordinates];
            break;
        }
        default:
            break;
    }
}

- (void)touchesBeganAtCoordinates:(PACoordinates *)coords
{
    if (self.currentTool == LINE_TOOL)
    {
        
    }
}

- (void)touchesEndedAtCoordinates:(PACoordinates *)coords
{
    if (self.drawingTemporaryImage)
    {
        [self.currentDrawing commitTemporaryImageUndoable:YES];
        self.drawingTemporaryImage = NO;
        NSSet *changedCoordinates = [self.currentDrawing coordinatesChangedSinceLastRead];
        [self.drawingView setNeedsDisplayInCoordinateSet:changedCoordinates];
    }
    else if (self.currentlyPainting)
    {
        self.currentlyPainting = NO;
        [self.currentDrawing saveStateAsUndoable];
    }
}


#pragma mark - PADrawingViewDataSource

- (UIColor *)colorAtDrawingCoordinates:(PACoordinates *)coords
{
    if (self.drawingTemporaryImage)
    {
        [self.currentDrawing markAsReadingTemporaryCoordinates];
        return [self.currentDrawing temporaryColorAtCoordinates:coords];
    }
    else
    {
        [self.currentDrawing markAsReadingCoordinates];
        return [self.currentDrawing colorAtCoordinates:coords];
    }
}

- (PASize *)drawingSize
{
    return self.currentDrawing.size;
}

- (CGSize)sizeOfZoomableDrawing
{
    return CGSizeMake(self.view.frame.size.width, self.view.frame.size.height);
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
        return 4;
    else if ([collectionView isEqual:self.optionsCollectionView])
        return 1;
    else if ([collectionView isEqual:self.toolsCollectionView])
        return 1;
    else
        return 0;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
    {
        if (section == 3)
            return 1;
        else
            return 7;
    }
    else if ([collectionView isEqual:self.optionsCollectionView])
    {
        return 3;
    }
    else if ([collectionView isEqual:self.toolsCollectionView])
    {
        //number of tools
        return [self.toolLables count];
    }
    else
        return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
    {
        if (indexPath.section == 3)
        {
            UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CustomColorButton"
                                                                                   forIndexPath:indexPath];
            return cell;
        }
        else
        {
            PAColorCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ColorCell"
                                                                          forIndexPath:indexPath];
            switch (indexPath.section)
            {
                case 0:
                {
                    cell.color = [self.rainbowColors objectAtIndex:indexPath.row];
                    break;
                }
                case 1:
                {
                    cell.color = [self.grayscaleColors objectAtIndex:indexPath.row];
                    break;
                }
                case 2:
                {
                    cell.color = [self.recentColors objectAtIndex:indexPath.row];
                    break;
                }
                    
                default:
                    break;
            }
            
            cell.colorIsSelected = [indexPath compare:self.selectedColorIndexPath] == NSOrderedSame;
            [cell setNeedsDisplay];
            return cell;
        }
    }
    else if ([collectionView isEqual:self.optionsCollectionView])
    {
        UICollectionViewCell *cell;
        switch (indexPath.item)
        {
            case 0:
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"UndoButton"
                                                                 forIndexPath:indexPath];
                break;
            case 1:
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"SaveButton"
                                                                 forIndexPath:indexPath];
                break;
            case 2:
                cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"DiscardButton"
                                                                 forIndexPath:indexPath];
                break;
            default:
                break;
        }
        return cell;
    }
    else if ([collectionView isEqual:self.toolsCollectionView])
    {
        UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"ToolButton"
                                                                               forIndexPath:indexPath];
        UILabel *label = (UILabel *)[cell viewWithTag:1];
        label.text = [self.toolLables objectAtIndex:indexPath.item];
        return cell;
    }
    else
        return nil;
}



#pragma mark - UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
    {
        if (indexPath.section == 3)
        {
            return CGSizeMake(300, 30);
        }
        else
        {
            return CGSizeMake(32, 30);
        }
    }
    else if ([collectionView isEqual:self.optionsCollectionView])
    {
        return CGSizeMake(93, 50);
    }
    else if ([collectionView isEqual:self.toolsCollectionView])
    {
        return CGSizeMake(93, 50);
    }
    else
    {
        return CGSizeMake(0, 0);
    }
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
    {
        switch (section)
        {
            //5's are between lines so add to make 10 between center lines
            case 0:
                return UIEdgeInsetsMake(10, 10, 5, 10);
                break;
            case 3:
                return UIEdgeInsetsMake(5, 10, 10, 10);
            default:
                return UIEdgeInsetsMake(5, 10, 5, 10);
                break;
        }
    }
    else if ([collectionView isEqual:self.optionsCollectionView])
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    else if ([collectionView isEqual:self.toolsCollectionView])
    {
        return UIEdgeInsetsMake(10, 10, 10, 10);
    }
    else
        return UIEdgeInsetsZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([collectionView isEqual:self.colorPickerCollectionView])
    {
        if (indexPath.section == 3)
        {
            HRColorPickerViewController* controller =
                [HRColorPickerViewController cancelableFullColorPickerViewControllerWithColor:[UIColor redColor]];
            controller.delegate = self;
            [self.navigationController setNavigationBarHidden:NO animated:YES];
            [self.navigationController pushViewController:controller animated:YES];
        }
        else
        {
            self.selectedColorIndexPath = indexPath;
            self.currentDrawingColor =
            ((PAColorCell *)[collectionView.dataSource collectionView:collectionView cellForItemAtIndexPath:indexPath]).color;
            [collectionView reloadData];
        }

    }
    else if ([collectionView isEqual:self.optionsCollectionView])
    {
        switch (indexPath.item)
        {
            //undo chosen
            case 0:
                [self undoDrawing];
                break;
            //save chosen
            case 1:
                [self goBackSaving:YES];
                break;
            //discard chosen
            case 2:
                [self goBackSaving:NO];
                break;
            default:
                break;
        }
    }
    else if ([collectionView isEqual:self.toolsCollectionView])
    {
        switch (indexPath.item)
        {
            case BRUSH_TOOL:
                self.currentTool = BRUSH_TOOL;
                break;
                
            case LINE_TOOL:
                self.currentTool = LINE_TOOL;
                break;
                
            case HAND_TOOL:
            {
                self.currentTool = HAND_TOOL;
                break;
            }
                
            default:
                break;
        }
        [self hideAllToolbars];
    }
    else
    {
        return;
    }
}

- (void)fillGestureRecognized:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        CGPoint location = [recognizer locationInView:self.drawingView];
        PACoordinates *coords = [self.drawingView coordinatesFromLocation:location];
        [self fillColorAroundSquareAtCoordinates:coords];
    }
}

#pragma mark - HRColorPickerViewControllerDelegate

- (void)setSelectedColor:(UIColor *)color
{
    self.currentDrawingColor = color;
    [self addRecentColor:color];
    self.selectedColorIndexPath = [NSIndexPath indexPathForItem:0 inSection:2];
}

#pragma mark - gesture recognizers

- (UILongPressGestureRecognizer *)fillGestureRecognizer
{
    if (!_fillGestureRecognizer)
    {
        _fillGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(fillGestureRecognized:)];
        _fillGestureRecognizer.minimumPressDuration = 0.5f;
    }
    return _fillGestureRecognizer;
}

- (UISwipeGestureRecognizer *)showColorsGestureRecognizer
{
    if (!_showColorsGestureRecognizer)
    {
        _showColorsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showColorPickerView)];
        _showColorsGestureRecognizer.numberOfTouchesRequired = 2;
        _showColorsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    }
    return _showColorsGestureRecognizer;
}

- (UISwipeGestureRecognizer *)hideColorsGestureRecognizer
{
    if (!_hideColorsGestureRecognizer)
    {
        _hideColorsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideColorPickerView)];
        _hideColorsGestureRecognizer.numberOfTouchesRequired = 2;
        _hideColorsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _hideColorsGestureRecognizer;
}

- (UISwipeGestureRecognizer *)showOptionsGestureRecognizer
{
    if (!_showOptionsGestureRecognizer)
    {
        _showOptionsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showOptionsView)];
        _showOptionsGestureRecognizer.numberOfTouchesRequired = 2;
        _showOptionsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionDown;
    }
    return _showOptionsGestureRecognizer;
}

- (UISwipeGestureRecognizer *)hideOptionsGestureRecognizer
{
    if (!_hideOptionsGestureRecognizer)
    {
        _hideOptionsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideOptionsView)];
        _hideOptionsGestureRecognizer.numberOfTouchesRequired = 2;
        _hideOptionsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
    }
    return _hideOptionsGestureRecognizer;
}

- (UISwipeGestureRecognizer *)showToolsGestureRecognizer
{
    if (!_showToolsGestureRecognizer)
    {
        _showToolsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showToolsView)];
        _showToolsGestureRecognizer.numberOfTouchesRequired = 2;
        _showToolsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    }
    return _showToolsGestureRecognizer;
}

- (UISwipeGestureRecognizer *)hideToolsGestureRecognizer
{
    if (!_hideToolsGestureRecognizer)
    {
        _hideToolsGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(hideToolsView)];
        _hideToolsGestureRecognizer.numberOfTouchesRequired = 2;
        _hideToolsGestureRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    }
    return _hideToolsGestureRecognizer;
}

- (void)removeToolbarShowGestureRecognizers
{
    NSLog(@"removing toolbar gesture recognizers");
    [self.drawingView removeGestureRecognizer:self.showColorsGestureRecognizer];
    [self.drawingView removeGestureRecognizer:self.showOptionsGestureRecognizer];
    [self.drawingView removeGestureRecognizer:self.showToolsGestureRecognizer];
}

- (void)addToolbarShowGestureRecognizers
{
    NSLog(@"adding toolbar gesture recognizers");
    [self.drawingView addGestureRecognizer:self.showColorsGestureRecognizer];
    [self.drawingView addGestureRecognizer:self.showOptionsGestureRecognizer];
    [self.drawingView addGestureRecognizer:self.showToolsGestureRecognizer];
}

- (UIPanGestureRecognizer *)handToolGestureRecognizer
{
    if (!_handToolGestureRecognizer)
    {
        _handToolGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handGestureRecognized:)];
        _handToolGestureRecognizer.minimumNumberOfTouches = 1;
        _handToolGestureRecognizer.maximumNumberOfTouches = 1;
    }
    return _handToolGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapZoomInGestureRecognizer
{
    if (!_doubleTapZoomInGestureRecognizer)
    {
        _doubleTapZoomInGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomGestureRecognized:)];
        _doubleTapZoomInGestureRecognizer.numberOfTapsRequired = 2;
        _doubleTapZoomInGestureRecognizer.numberOfTouchesRequired = 1;
    }
    return _doubleTapZoomInGestureRecognizer;
}

- (UITapGestureRecognizer *)doubleTapZoomOutGestureRecognizer
{
    if (!_doubleTapZoomOutGestureRecognizer)
    {
        _doubleTapZoomOutGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(zoomGestureRecognized:)];
        _doubleTapZoomOutGestureRecognizer.numberOfTapsRequired = 2;
        _doubleTapZoomOutGestureRecognizer.numberOfTouchesRequired = 2;
    }
    return _doubleTapZoomOutGestureRecognizer;
}

#pragma mark - navigation

- (void)goBackSaving:(BOOL)save
{
    if (save)
    {
        
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)showColorPickerView
{
    NSLog(@"color");
    if (self.toolbarShowing == NO_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect pickerFrame = self.colorPickerCollectionView.frame;
            pickerFrame.origin.y -= pickerFrame.size.height;
            self.colorPickerCollectionView.frame = pickerFrame;
        }];
        self.toolbarShowing = COLOR_PICKER_TOOLBAR;
        
        //color picker gesture recognizer
        [self.drawingView addGestureRecognizer:self.hideColorsGestureRecognizer];
    }
    [self removeToolbarShowGestureRecognizers];
}

- (void)hideColorPickerView
{
    if (self.toolbarShowing == COLOR_PICKER_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect pickerFrame = self.colorPickerCollectionView.frame;
            pickerFrame.origin.y += pickerFrame.size.height;
            self.colorPickerCollectionView.frame = pickerFrame;
        }];
        self.toolbarShowing = NO_TOOLBAR;
        
        //color picker gesture recognizer
        [self addToolbarShowGestureRecognizers];
    }
    [self.drawingView removeGestureRecognizer:self.hideColorsGestureRecognizer];
}

- (void)showOptionsView
{
    NSLog(@"options");
    if (self.toolbarShowing == NO_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect optionsFrame = self.optionsCollectionView.frame;
            optionsFrame.origin.y += optionsFrame.size.height;
            self.optionsCollectionView.frame = optionsFrame;
        }];
        self.toolbarShowing = OPTIONS_TOOLBAR;
        
        [self.drawingView addGestureRecognizer:self.hideOptionsGestureRecognizer];
    }
    [self removeToolbarShowGestureRecognizers];
}

- (void)hideOptionsView
{
    if (self.toolbarShowing == OPTIONS_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect optionsFrame = self.optionsCollectionView.frame;
            optionsFrame.origin.y -= optionsFrame.size.height;
            self.optionsCollectionView.frame = optionsFrame;
        }];
        self.toolbarShowing = NO_TOOLBAR;
        
        [self addToolbarShowGestureRecognizers];
    }
    [self.drawingView removeGestureRecognizer:self.hideOptionsGestureRecognizer];
}

- (void)showToolsView
{
    NSLog(@"tools");
    if (self.toolbarShowing == NO_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect toolsFrame = self.toolsCollectionView.frame;
            toolsFrame.origin.x += toolsFrame.size.width;
            self.toolsCollectionView.frame = toolsFrame;
        }];
        self.toolbarShowing = DRAWING_TOOLS_TOOLBAR;
        
        [self.drawingView addGestureRecognizer:self.hideToolsGestureRecognizer];
    }
    [self removeToolbarShowGestureRecognizers];
}

- (void)hideToolsView
{
    if (self.toolbarShowing == DRAWING_TOOLS_TOOLBAR)
    {
        [UIView animateWithDuration:0.3 animations:^{
            CGRect toolsFrame = self.toolsCollectionView.frame;
            toolsFrame.origin.x -= toolsFrame.size.width;
            self.toolsCollectionView.frame = toolsFrame;
        }];
        self.toolbarShowing = NO_TOOLBAR;
        
        [self addToolbarShowGestureRecognizers];
    }
    [self.drawingView removeGestureRecognizer:self.hideToolsGestureRecognizer];
}

- (void)hideAllToolbars
{
    if (self.toolbarShowing)
    {
        [self hideColorPickerView];
        [self hideOptionsView];
        [self hideToolsView];
    }
}

#pragma mark - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(float)scale
{
    view.contentScaleFactor = 1.5f*scale;
    
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.drawingView;
}


@end
