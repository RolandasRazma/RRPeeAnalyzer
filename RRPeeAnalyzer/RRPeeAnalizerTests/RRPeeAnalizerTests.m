//
//  RRPeeAnalizerTests.m
//  RRPeeAnalizerTests
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

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "UIImage+UIColorAdditions.h"
#import "UIImage+RRTransformsAdditions.h"
#import "UIImage+RRDrawingAddition.h"
#import "UIImage+NSStringAdditions.h"
#import "RRStripAnalyzer.h"
#import "RRStripAnalyzerTest.h"
#import "Colours.h"


@interface RRPeeAnalizerTests : XCTestCase

@end


@implementation RRPeeAnalizerTests {
    NSString *_cachesPath;
}


#pragma mark -
#pragma mark XCTestCase


- (void)setUp {
    [super setUp];

    _cachesPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: @"Tests"];
#if TARGET_IPHONE_SIMULATOR
    _cachesPath = @"/Users/GameBit/Desktop/RRPeeAnalizer/";
    [[NSFileManager defaultManager] createDirectoryAtPath: _cachesPath
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: NULL];
#endif
}


- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}


#pragma mark -
#pragma mark RRPeeAnalizerTests


- (void)testImageCroping {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    CGRect newFrame = CGRectMake(20, 100, frameImage.size.width -250, frameImage.size.height -100);
    
    frameImage = [frameImage imageByCropingToBounds:newFrame];
    XCTAssertNotNil(frameImage, @"Can't crop image");
    XCTAssertEqual(newFrame.size.width,  frameImage.size.width);
    XCTAssertEqual(newFrame.size.height, frameImage.size.height);
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testImageCroping.jpg"]
                                                  atomically: YES];
    
}


- (void)testImageRotation {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    frameImage = [frameImage imageRotateByAngle:30 *M_PI /180.0f];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testImageRotation.jpg"]
                                                  atomically: YES];
    
}


- (void)testLightCalibration {

    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"frameImage.jpg"]
                                                  atomically: YES];
    
    
    UIImage *lightCalibrationMask = [frameImage lightCalibrationMaskForRect:CGRectMake(10, 0, 10, frameImage.size.height)];
    XCTAssertNotNil(lightCalibrationMask, @"Can't create light calibration mask");
    
    [UIImagePNGRepresentation(lightCalibrationMask) writeToFile: [_cachesPath stringByAppendingPathComponent: @"lightCalibrationMask.png"]
                                                     atomically: YES];
    
    
    UIImage *lightCalibratedImage = [frameImage imageByApplyingLightCalibrationMask:lightCalibrationMask];
    XCTAssertNotNil(lightCalibratedImage, @"Can't create light calibrated image");
    
    [UIImageJPEGRepresentation(lightCalibratedImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"lightCalibratedImage.jpg"]
                                                            atomically: YES];
    
}


- (void)testLightCalibrationMaskPerformance {

    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    // performance test case.
    [self measureBlock: ^{

        UIImage *lightCalibrationMask = [frameImage lightCalibrationMaskForRect:CGRectMake(10, 0, 10, frameImage.size.height)];
        XCTAssertNotNil(lightCalibrationMask, @"Can't create light calibration mask");
        
    }];
    
}


- (void)testLightCalibrationPerformance {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    UIImage *lightCalibrationMask = [frameImage lightCalibrationMaskForRect:CGRectMake(10, 0, 10, frameImage.size.height)];
    XCTAssertNotNil(lightCalibrationMask, @"Can't create light calibration mask");

    // performance test case.
    [self measureBlock: ^{
        
        UIImage *lightCalibratedImage = [frameImage imageByApplyingLightCalibrationMask:lightCalibrationMask];
        XCTAssertNotNil(lightCalibratedImage, @"Can't create light calibrated image");
        
    }];
    
}


- (void)testStripBoundsDetect {

    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
  
    // RRStripAnalyzer
    RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
    CGRect bounds = [stripAnalyzer rectForStrip];

    XCTAssertTrue(!CGRectIsEmpty(bounds));
    
    frameImage = [frameImage imageByCropingToBounds:bounds];
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testStripBoundsDetect.jpg"]
                                                  atomically: YES];
    
}


- (void)testStripBoundsDetectPerformance {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    // performance test case.
    [self measureBlock: ^{
        
        // RRStripAnalyzer
        RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
        XCTAssertTrue(!CGRectIsEmpty([stripAnalyzer rectForStrip]));

    }];
    
}


- (void)testStripTestDetect {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");

    // RRStripAnalyzer
    RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
    for( int testIndex=0; testIndex<10; testIndex++ ){
        CGRect bounds = [stripAnalyzer rectForTestAtIndex:testIndex];
        XCTAssertTrue(!CGRectIsEmpty(bounds));
        
        frameImage = [frameImage imageByDrawingEllipseInRect:bounds];
    }
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testStripTestDetect.jpg"]
                                                  atomically: YES];
}


- (void)testStripTestDetectPerformance {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    // RRStripAnalyzer
    RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
    XCTAssertTrue(!CGRectIsEmpty([stripAnalyzer rectForStrip]));
    
    // performance test case.
    [self measureBlock: ^{
        CGRect bounds = [stripAnalyzer rectForTestAtIndex:9];
        XCTAssertTrue(!CGRectIsEmpty(bounds));
    }];
    
}


- (void)testStripTestColorDetect {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");
    
    // RRStripAnalyzer
    RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
    
    for( int testIndex=0; testIndex<10; testIndex++ ){
        UIColor *color = [stripAnalyzer colorForTestAtIndex:testIndex];
        XCTAssertNotNil(color, @"Can't get color");

        CGRect testRect = [stripAnalyzer rectForTestAtIndex:testIndex];
        frameImage = [frameImage imageByDrawingEllipseInRect:CGRectOffset(testRect, CGRectGetWidth(testRect), 0) fillColor:color];
    }
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testStripTestColorDetect.jpg"]
                                                  atomically: YES];
    
}


- (void)testStripColorCompare {
    
    UIImage *frameImage = [UIImage imageNamed:@"RRCaptureSessionStill.jpg"];
    XCTAssertNotNil(frameImage, @"Can't load image");

    
    UIImage *lightCalibrationMask = [frameImage lightCalibrationMaskForRect:CGRectMake(10, 0, 10, frameImage.size.height)];
    XCTAssertNotNil(lightCalibrationMask, @"Can't create light calibration mask");
    
    frameImage = [frameImage imageByApplyingLightCalibrationMask:lightCalibrationMask];
    XCTAssertNotNil(frameImage, @"Can't create light calibrated image");
    
    // RRStripAnalyzer
    RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];

    for( int testIndex=0; testIndex<10; testIndex++ ){
        RRStripAnalyzerTest *stripAnalyzerTest = [stripAnalyzer testAtIndex:testIndex];
        XCTAssertNotNil(stripAnalyzerTest, @"Can't get RRStripAnalyzerTest");
        
        CGRect testRect = [stripAnalyzer rectForTestAtIndex:testIndex];
        UIColor *color = [stripAnalyzer colorForTestAtIndex:testIndex];
        
        frameImage = [frameImage imageByDrawingEllipseInRect: CGRectOffset(testRect, -CGRectGetWidth(testRect), 0)
                                                   fillColor: color];
        
        frameImage = [frameImage imageByAddingText: [NSString stringWithFormat:@"%@ [%@] (%.f)", stripAnalyzerTest.type, stripAnalyzerTest.value, roundf([color distanceFromColor:stripAnalyzerTest.color])]
                                             color: color
                                        atPosition: CGRectOffset(testRect, CGRectGetWidth(testRect), 7).origin];
    }
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: @"testStripColorCompare.jpg"]
                                                  atomically: YES];
}


@end
