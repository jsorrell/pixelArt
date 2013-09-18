//
//  PASize.m
//  pixelArt
//
//  Created by Jack Sorrell on 8/3/13.
//  Copyright (c) 2013 Jack Sorrell. All rights reserved.
//

#import "PASize.h"

@implementation PASize
{
    NSUInteger _width;
    NSUInteger _height;
}

#pragma mark - properties

- (NSUInteger)width
{
    return _width;
}
- (NSUInteger)height
{
    return _height;
}

- (NSUInteger)area
{
    return self.width * self.height;
}

- (NSUInteger)perimeter
{
    return 2*(self.width + self.height);
}

#pragma mark - initiation
- (id)initWithWidth:(NSUInteger)width Height:(NSUInteger)height
{
    if (self = [super init])
    {
        _width = width;
        _height = height;
    }
    return self;
}

+ (id)sizeWithWidth:(NSUInteger)width Height:(NSUInteger)height
{
    return [[self alloc] initWithWidth:width Height:height];
}

- (id)initWithWidth:(NSUInteger)width HeightWidthRatio:(CGFloat)ratio
{
    NSUInteger height = (NSUInteger)(fabsf(ratio) * (CGFloat)width + 0.5f);
    return [self initWithWidth:width Height:height];
}

+ (id)sizeWithWidth:(NSUInteger)width HeightWidthRatio:(CGFloat)ratio
{
    return [[self alloc] initWithWidth:width HeightWidthRatio:ratio];
}

- (id)initWithHeight:(NSUInteger)height HeightWidthRatio:(CGFloat)ratio
{
    NSUInteger width = (NSUInteger)((CGFloat)height/fabsf(ratio) + 0.5f);
    return [self initWithWidth:width Height:height];
}

+ (id)sizeWithHeight:(NSUInteger)height HeightWidthRatio:(CGFloat)ratio
{
    return [[self alloc] initWithHeight:height HeightWidthRatio:ratio];
}

#pragma mark - NSObject overrides

- (BOOL)isEqual:(id)object
{
    if ([object isKindOfClass:[self class]])
    {
        PASize *test = object;
        return test.width == self.width &&
        test.height == self.height;
    }
    else
    {
        return NO;
    }
}

- (NSUInteger)hash
{
    return self.width * 31 + self.height;
}

- (id)copy
{
    return [[self class] sizeWithWidth:self.width Height:self.height];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"[%d,%d]",self.width,self.height];
}

@end
