//
//  UIImage+RRDrawingAddition.m
//
//  Created by Rolandas Razma on 18/02/2015.
//  Copyright (c) 2015 Rolandas Razma. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
//  restriction, including without limitation the rights to use,
//  copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the
//  Software is furnished to do so, subject to the following
//  conditions:
//
//  The above copyright notice and this permission notice shall be
//  included in all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
//  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
//  OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
//  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
//  HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
//  WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
//  OTHER DEALINGS IN THE SOFTWARE.
//

#import "UIImage+RRDrawingAddition.h"


@implementation UIImage (RRDrawingAddition)


- (UIImage *)imageByDrawingCircleWithCenter:(CGPoint)center radius:(CGFloat)radius {
    return [self imageByDrawingEllipseInRect:CGRectMake(center.x -radius, center.y -radius, radius *2, radius *2)];
}


- (UIImage *)imageByDrawingEllipseInRect:(CGRect)rect {
    return [self imageByDrawingEllipseInRect:rect fillColor:nil];
}


- (UIImage *)imageByDrawingEllipseInRect:(CGRect)rect fillColor:(UIColor *)fillColor {
    // begin a graphics context of sufficient size
    UIGraphicsBeginImageContext(self.size);
    
    // draw original image into the context
    [self drawAtPoint:CGPointZero];
    
    // get the context for CoreGraphics
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    if( fillColor ){
        [fillColor setFill];
        
        // Fill the circle with the fill color
        CGContextFillEllipseInRect(ctx, rect);
    }else{
        // set stroking color and draw circle
        [[UIColor redColor] setStroke];
    }
    
    // draw circle
    CGContextStrokeEllipseInRect(ctx, rect);
    
    // make image out of bitmap context
    UIImage *retImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // free the context
    UIGraphicsEndImageContext();
    
    return retImage;
}


@end
