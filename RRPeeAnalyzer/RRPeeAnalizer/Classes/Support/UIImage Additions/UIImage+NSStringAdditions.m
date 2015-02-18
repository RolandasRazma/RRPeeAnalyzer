//
//  UIImage+NSStringAdditions.m
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

#import "UIImage+NSStringAdditions.h"


@implementation UIImage (NSStringAdditions)


- (UIImage *)imageByAddingText:(NSString *)text atPosition:(CGPoint)position {
    return [self imageByAddingText: text
                             color: [UIColor blackColor]
                        atPosition: position];
}

- (UIImage *)imageByAddingText:(NSString *)text color:(UIColor *)color atPosition:(CGPoint)position {
    UIGraphicsBeginImageContext(self.size);
    
    [self drawInRect:CGRectMake(0, 0, self.size.width, self.size.height)];
    
    NSMutableAttributedString *attString = [[NSMutableAttributedString alloc] initWithString: text];
    NSRange range = NSMakeRange(0, [attString length]);
    
    [attString addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:21]      range:range];
    [attString addAttribute:NSForegroundColorAttributeName value:color                  range:range];
    
    [attString drawInRect: CGRectMake(position.x, position.y, self.size.width, self.size.height)];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}


@end
