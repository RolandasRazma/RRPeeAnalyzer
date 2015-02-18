//
//  UIImage+RRTransformsAdditions.m
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

#import "UIImage+RRTransformsAdditions.h"


@implementation UIImage (RRTransformsAdditions)


- (UIImage *)imageByCropingToBounds:(CGRect)bounds {
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], bounds);
    UIImage *image = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    
    return image;
}


- (UIImage *)imageRotateByAngle:(CGFloat)angle {
    
    angle *= -1;
    
    CGRect bounds = CGRectMake(0, 0, self.size.width, self.size.height);
    CGRect rotatedRect = CGRectIntegral(CGRectApplyAffineTransform(bounds, CGAffineTransformMakeRotation(angle)));

    size_t width = rotatedRect.size.width;
    size_t height= rotatedRect.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();

    CGContextRef imageContextRef = CGBitmapContextCreate(NULL, width, height, 8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextSetShouldAntialias(imageContextRef, true);
    CGContextSetAllowsAntialiasing(imageContextRef, true);
    CGContextSetInterpolationQuality(imageContextRef, kCGInterpolationHigh);
    
    CGContextFillRect(imageContextRef, CGRectInset(rotatedRect, -rotatedRect.size.width, -rotatedRect.size.height));
    
    CGContextTranslateCTM(imageContextRef, rotatedRect.size.width *0.5f, rotatedRect.size.height *0.5f);
    CGContextRotateCTM(imageContextRef, angle);
    
    CGContextDrawImage(imageContextRef, CGRectMake(-self.size.width *0.5f, -self.size.height *0.5f, self.size.width, self.size.height), self.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(imageContextRef);
    UIImage *rotatedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CFRelease(imageRef);
    
    CGContextRelease(imageContextRef);
    
    CGColorSpaceRelease(colorSpace);

    return rotatedImage;
}


@end
