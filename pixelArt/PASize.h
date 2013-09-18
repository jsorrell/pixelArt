//
//  PASize.h
//  pixelArt
//
//  Created by Jack Sorrell on 8/3/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PASize : NSObject

#pragma mark - properties
@property (nonatomic,readonly) NSUInteger width;
@property (nonatomic,readonly) NSUInteger height;
@property (nonatomic,readonly) NSUInteger area;
@property (nonatomic,readonly) NSUInteger perimeter;

#pragma mark - initiation
- (id)initWithWidth:(NSUInteger)width Height:(NSUInteger)height;
+ (id)sizeWithWidth:(NSUInteger)width Height:(NSUInteger)height;

//round to closest
- (id)initWithWidth:(NSUInteger)width HeightWidthRatio:(CGFloat)ratio;
+ (id)sizeWithWidth:(NSUInteger)width HeightWidthRatio:(CGFloat)ratio;
- (id)initWithHeight:(NSUInteger)height HeightWidthRatio:(CGFloat)ratio;
+ (id)sizeWithHeight:(NSUInteger)height HeightWidthRatio:(CGFloat)ratio;
@end
