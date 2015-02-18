//
//  UIImage+UIColorAdditions.m
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

#import "UIImage+UIColorAdditions.h"


@implementation UIImage (UIColorAdditions)


- (UIImage *)lightCalibrationMaskForRect:(CGRect)rect {
    
    const int RED   = 1;
    const int GREEN = 2;
    const int BLUE  = 3;
    
    size_t width = rect.size.width;
    size_t height= rect.size.height;
    
    // Crop
    CGImageRef cropedImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    rect = CGRectMake(0.0f, 0.0f, width, height);
    
    // Convert to mask
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    uint32_t *rawData = (uint32_t *)malloc(width *height *sizeof(uint32_t));
    CGContextRef maskContextRef = CGBitmapContextCreate(rawData, width, height, 8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextSetInterpolationQuality(maskContextRef, kCGInterpolationHigh);
    CGContextSetAllowsAntialiasing(maskContextRef, false);
    CGContextDrawImage(maskContextRef, rect, cropedImage);
    CGImageRelease(cropedImage);
    
    // create alpha gradient
    uint8_t minValue = 255;
    for( int y = 0; y < height; y++ ) {
        int rowTotal = 0;
        for( int x = 0; x < width; x++ ) {
            uint8_t *rgbaPixel = (uint8_t *)&rawData[y *width +x];
            rowTotal += (uint8_t)((30 *rgbaPixel[RED] +59 *rgbaPixel[GREEN] +11 *rgbaPixel[BLUE]) /100);
        }
        
        uint8_t rowMedian = (uint8_t)(roundf((float)rowTotal /(float)width));
        for( int x = 0; x < width; x++ ) {
            uint8_t *rgbaPixel = (uint8_t *)&rawData[y *width +x];
            rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = rowMedian;
            
            minValue = MIN(minValue, rowMedian);
        }
    }
    
    // normalize gradient
    uint8_t minAValue = 255;
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *)&rawData[y *width +x];
            rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = 255 -(rgbaPixel[RED] -minValue);
            minAValue = MIN(minAValue, rgbaPixel[RED]);
        }
    }
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *)&rawData[y *width +x];
            rgbaPixel[RED] = rgbaPixel[GREEN] = rgbaPixel[BLUE] = rgbaPixel[RED] -minAValue /2;
        }
    }

    
    // create mask image
    CGImageRef imageRef = CGBitmapContextCreateImage(maskContextRef);
    UIImage *maskImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CFRelease(imageRef);
    
    CGContextRelease(maskContextRef);
    CGColorSpaceRelease(colorSpace);
    free(rawData);

    return maskImage;
}


- (UIImage *)imageByApplyingLightCalibrationMask:(UIImage *)image {
    
    size_t width = self.size.width;
    size_t height= self.size.height;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    
    // scale and blur mask
    CGContextRef maskContextRef = CGBitmapContextCreate(NULL, width, height, 8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextSetInterpolationQuality(maskContextRef, kCGInterpolationHigh);
    CGContextDrawImage(maskContextRef, CGRectMake(0, 0, width, height), image.CGImage);
    
    CGImageRef maskImageRef = CGBitmapContextCreateImage(maskContextRef);
    
    CIFilter *gaussianBlurFilter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [gaussianBlurFilter setDefaults];
    [gaussianBlurFilter setValue:[CIImage imageWithCGImage:maskImageRef] forKey:kCIInputImageKey];
    [gaussianBlurFilter setValue:@5 forKey:kCIInputRadiusKey];
    
    CIImage *outputImage = [gaussianBlurFilter outputImage];
    
    CFRelease(maskImageRef);
    CGContextRelease(maskContextRef);
    
    CIContext *context  = [CIContext contextWithOptions:nil];

    CGRect rect = [outputImage extent];
    rect.origin.x       += floorf((rect.size.width  -width ) /2.0f);
    rect.origin.y       += floorf((rect.size.height -height) /2.0f);
    rect.size            = self.size;
    
    CGImageRef bluredImageRef = [context createCGImage:outputImage fromRect:rect];
    image = [UIImage imageWithCGImage:bluredImageRef scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(bluredImageRef);

    
    // apply mask
    CGContextRef imageContextRef = CGBitmapContextCreate(NULL, width, height, 8, width *sizeof(uint32_t), colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    CGContextSetInterpolationQuality(imageContextRef, kCGInterpolationHigh);
    
    CGContextDrawImage(imageContextRef, CGRectMake(0, 0, width, height), self.CGImage);
    CGContextSetBlendMode(imageContextRef, kCGBlendModeOverlay);
    CGContextDrawImage(imageContextRef, CGRectMake(0, 0, width, height), image.CGImage);
    
    CGImageRef imageRef = CGBitmapContextCreateImage(imageContextRef);
    UIImage *maskedImage = [UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CFRelease(imageRef);
    
    CGContextRelease(imageContextRef);
    
    
    CGColorSpaceRelease(colorSpace);
    
    
    return maskedImage;
}


- (UIColor *)dominantColorForRect:(CGRect)rect {
    
    // Crop
    CGImageRef cropedImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    unsigned char rgba[4];
    CGContextRef context = CGBitmapContextCreate(rgba, 1, 1, 8, 4, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
    
    CGContextDrawImage(context, CGRectMake(0, 0, 1, 1), cropedImage);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);
    
    if( rgba[3] > 0 ) {
        CGFloat alpha = ((CGFloat)rgba[3])/255.0;
        CGFloat multiplier = alpha/255.0;
        return [UIColor colorWithRed:((CGFloat)rgba[0])*multiplier
                               green:((CGFloat)rgba[1])*multiplier
                                blue:((CGFloat)rgba[2])*multiplier
                               alpha:alpha];
    } else {
        return [UIColor colorWithRed:((CGFloat)rgba[0])/255.0
                               green:((CGFloat)rgba[1])/255.0
                                blue:((CGFloat)rgba[2])/255.0
                               alpha:((CGFloat)rgba[3])/255.0];
    }
    
    return nil;
}


@end