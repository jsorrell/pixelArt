//
//  PAColorCell.h
//  pixelArt
//
//  Created by Jack Sorrell on 7/29/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PAColorCell : UICollectionViewCell
@property (nonatomic,strong) UIColor *color;
@property (nonatomic) BOOL colorIsSelected;
@end
