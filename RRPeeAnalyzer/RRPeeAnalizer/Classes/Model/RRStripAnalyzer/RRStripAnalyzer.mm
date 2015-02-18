//
//  RRStripAnalyzer.m
//  RRPeeAnalizer
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

#import "RRStripAnalyzer.h"
#import <opencv2/opencv.hpp>
#import "RRCVAdditions.hpp"
#import "UIImage+OpenCVAdditions.h"
#import "UIImage+UIColorAdditions.h"
#import "RRStripAnalyzerTest.h"
#import "Colours.h"


#define WRITE(__FILENAME__, __MAT__) [UIImageJPEGRepresentation([UIImage imageWithMatrix:__MAT__], 1.0f) writeToFile:[NSString stringWithFormat:@"/Users/GameBit/Desktop/RRPeeAnalizer/%@.jpg", __FILENAME__] atomically:YES];


CGRect CGRectFromRotatedRect(cv::RotatedRect rotatedRect) {
    cv::Rect boundingRect = rotatedRect.boundingRect();
    if( boundingRect.height == 1.0f && boundingRect.width == 1.0f && rotatedRect.angle == 0.0f && rotatedRect.center.x == 0.0f && rotatedRect.center.y == 0.0f ){
        return CGRectNull;
    }
    return CGRectMake(boundingRect.x, boundingRect.y, boundingRect.width, boundingRect.height);
}


@implementation RRStripAnalyzer {
    UIImage         *_image;
    NSArray         *_tests;
    
    cv::RotatedRect _rectForStrip;
    dispatch_once_t _rectForStripToken;
    
    cv::RotatedRect _rectForTest[10];
    dispatch_once_t _rectForTestToken;
}


#pragma mark -
#pragma mark RRStripAnalyzer


+ (CGRect)rectInImage:(UIImage *)image atPoint:(CGPoint)point {
    
    cv::Mat matToProcess;
    cv::medianBlur([image matrix], matToProcess, 5);
    cv::cvtColor(matToProcess, matToProcess, cv::COLOR_BGR2GRAY);

    // find largest rect
    cv::Rect rectangle = cv::rr::findRectangle(matToProcess, cv::Point(point.x, point.y)).boundingRect();

    if( rectangle.width <= 1 || rectangle.height <= 1 ){
        return CGRectNull;
    }
    
    return CGRectMake(rectangle.x, rectangle.y, rectangle.width, rectangle.height);
}


- (instancetype)initWithImage:(UIImage *)image {
    if ( (self = [super init]) ){
        _image = image;
    }
    
    return self;
}


- (NSArray *)tests {
    if( !_tests ){
        _tests = [[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DUS10" ofType:@"plist"]] copy];
    };
    
    return _tests;
}


- (CGRect)rectForStrip {
    return CGRectFromRotatedRect([self _rectForStrip]);
}


- (cv::RotatedRect)_rectForStrip {
    
    dispatch_once(&_rectForStripToken, ^{
        
        cv::Mat imageBlurMat;
        cv::medianBlur([_image matrix], imageBlurMat, 5);
        
        // Find stip rect
        _rectForStrip = cv::rr::findLargestRectangle(imageBlurMat, 0.2f, 0.0f, true);
        
    });

    return _rectForStrip;
}


- (CGRect)rectForTestAtIndex:(NSUInteger)index {
    return CGRectFromRotatedRect([self _rectForTestAtIndex:index]);
}


- (cv::RotatedRect)_rectForTestAtIndex:(NSUInteger)index {
    
    dispatch_once(&_rectForTestToken, ^{
        cv::RotatedRect stripRect = [self _rectForStrip];

        float stripWidth  = MIN(stripRect.size.width, stripRect.size.height);
        float stripHeight = MAX(stripRect.size.width, stripRect.size.height);
        
        // No point in looking for tests if strip not found
        if( stripWidth <= 1.0f ){
            return;
        }
        
        
        // find squares
        std::vector<cv::RotatedRect> squares;
        
        cv::Mat matToProcess([_image matrix]);
        cv::medianBlur(matToProcess, matToProcess, 9);
        
        cv::rr::enumerate::findConvexPolysCT(matToProcess, [&](std::vector<cv::Point> approx){
            cv::RotatedRect boundingRect = cv::minAreaRect(cv::Mat(approx));
            
            float widthHeightRatio = ((boundingRect.size.width <= boundingRect.size.height)?(float)boundingRect.size.width /(float)boundingRect.size.height:(float)boundingRect.size.height /(float)boundingRect.size.width);
            float ratioToStrip = stripWidth /(float)boundingRect.size.width;
            if(    widthHeightRatio >= 0.7f
                && ratioToStrip >= 0.3f
                && ratioToStrip <= 1.5f
                && cv::rr::geometry::intersect(boundingRect, squares) == -1
                && cv::rr::geometry::intersects(boundingRect, stripRect)
            ){
                squares.push_back(boundingRect);
            }
        });
        
        // 3 quares not enaugh...
        if( squares.size() < 3  ){
            return;
        }
        
        // Oriantation
        BOOL isVertical = cv::abs(squares[0].center.x -squares[1].center.x) < cv::abs(squares[0].center.y -squares[1].center.y);
        
        // Sort
        cv::rr::geometry::sort(squares, isVertical);

        // Remove lowest rect as sometimes white space at bottom is detected
        squares.pop_back();

        
        size_t squaresLength = squares.size();

        
        // Unify sizes
        float testSize=0;
        for ( int i = 0; i < squaresLength; i++ ) {
            testSize += MIN(stripWidth, squares[i].size.width) +MIN(stripWidth, squares[i].size.height);
        }
        testSize = roundf(testSize /(squaresLength *2.0f));
        
        for ( int i = 0; i < squaresLength; i++ ) {
            squares[i].size.height = squares[i].size.width = testSize;
        }
        
        float angle = cv::rr::math::angle(squares[0].center, squares[squares.size() -1].center);
        float gapSize = MAX(squares[0].size.width, squares[1].size.height);
        
        
        // min gap between squares
        for ( int i = 0; i < squaresLength -1; i++ ) {
            gapSize = MIN(gapSize, cv::rr::math::distance(squares[i].center, squares[i +1].center));
        }
        
        
        // compute missing squares
        for ( int i = 0; i < squaresLength -1; i++ ) {
            float distance = cv::rr::math::distance(squares[i].center, squares[i +1].center);
            size_t missingSquares = roundf((distance -squares[i].size.width) /(squares[i].size.width +gapSize));

            // add missing squares
            for( int missingSquareIndex=1; missingSquareIndex<=missingSquares; missingSquareIndex++ ){
                cv::Point2f nextCenter = squares[i].center;
                nextCenter.y += distance /(missingSquares +1) *missingSquareIndex *sin(angle);
                nextCenter.x += distance /(missingSquares +1) *missingSquareIndex *cos(angle);

                squares.push_back( cv::RotatedRect(nextCenter, squares[i].size, angle) );
            }
        }


        
        // add missing squares to top
        cv::Point2f stripTopCenter = stripRect.center;
        stripTopCenter.y -= stripHeight /2.0f *sin(angle);
        stripTopCenter.x -= stripHeight /2.0f *cos(angle);

        while ( cv::rr::math::distance(stripTopCenter, squares[0].center) > testSize *1.5f ) {
            cv::RotatedRect nextRect(squares[0]);
            nextRect.center.y -= testSize *1.5f *sin(angle);
            nextRect.center.x -= testSize *1.5f *cos(angle);
            
            squares.insert(squares.begin(), nextRect);
        }

        
        // add missing squares to bottom
        while ( squares.size() != 10 ) {
            cv::RotatedRect nextRect(squares[squares.size() -1]);
            nextRect.center.y += testSize *1.5f *sin(angle);
            nextRect.center.x += testSize *1.5f *cos(angle);
            
            squares.push_back(nextRect);
        }
        
        
        // Sort
        cv::rr::geometry::sort(squares, isVertical);
        
        
        // cache
        squaresLength = squares.size();
        for ( int i = 0; i < squaresLength; i++ ) {
            _rectForTest[i] = squares[i];
        }
    });
    
    return _rectForTest[index];
}


- (UIColor *)colorForTestAtIndex:(NSUInteger)index {

    CGRect bounds = [self rectForTestAtIndex:index];
    
    if( CGRectIsEmpty(bounds) ){
        return nil;
    }
    
    // inset rect to compensate for possible detection mistakes
    bounds = CGRectIntegral(CGRectInset(bounds, CGRectGetWidth(bounds) *0.10f, CGRectGetHeight(bounds) *0.10f));
    
    return [_image dominantColorForRect: bounds];

}


- (RRStripAnalyzerTest *)testAtIndex:(NSUInteger)index {
    
    UIColor *color = [self colorForTestAtIndex:index];
    
    if( !color ){
        return nil;
    }
    
    NSArray *testRow = [[self tests] objectAtIndex:index];

    // Compare colors
    CGFloat closestDistance = CGFLOAT_MAX;
    RRStripAnalyzerTest *closestTestMatch;
    for( RRStripAnalyzerTest *test in testRow ){
        CGFloat distance = [test.color distanceFromColor:color];
        if( closestDistance > distance ){
            closestDistance = distance;
            closestTestMatch= [test copy];
        }
    }
    
    [closestTestMatch setRect: [self rectForTestAtIndex:index]];
    
    return closestTestMatch;
}


@end
