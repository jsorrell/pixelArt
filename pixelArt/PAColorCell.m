//
//  PAColorCell.m
//  pixelArt
//
//  Created by Jack Sorrell on 7/29/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PAColorCell.h"

@interface PAColorCell ()
{
//    UIColor *_color;
//    BOOL _colorIsSelected;
}

@end

@implementation PAColorCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        // Initialization code
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGFloat selectedBorderWidth = 3.0f;

    //get the context
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //set the line width
    CGContextSetLineWidth(context, selectedBorderWidth);
    //and stroke color
    CGContextSetStrokeColorWithColor(context,[UIColor darkGrayColor].CGColor);
    //and fill color
    CGContextSetFillColorWithColor(context, self.color.CGColor);
    
    //fill rectangle
    CGContextFillRect(context, rect);
    
    //make and add the rectangle to path
    CGContextAddRect(context, rect);
    
    //stroke the path if selected
    if (self.colorIsSelected)
        CGContextStrokePath(context);
}

- (UIColor *)color
{
    if (!_color)
    {
        _color = [UIColor whiteColor];
    }
    return _color;
}

@end
