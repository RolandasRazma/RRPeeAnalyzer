//
//  RRCaptureViewController.m
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

#import "RRCaptureViewController.h"
#import "UIImage+NSStringAdditions.h"
#import "UIImage+UIColorAdditions.h"
#import "UIImage+RRTransformsAdditions.h"
#import "RRCaptureSession.h"
#import "RRStripAnalyzer.h"


@interface RRCaptureViewController () <RRCaptureSessionDelegate>

@end


@implementation RRCaptureViewController {
    __weak IBOutlet UIButton *_actionButton;
    
    RRCaptureSession    *_captureSession;
    
    NSTimer             *_frameCaptureTimer;
    NSDate              *_startTime;
    NSString            *_cachesPath;
    
    CALayer             *_focusRectLayer;
    
    CGRect              _focusRect;
}


#pragma mark -
#pragma mark NSCoding


- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super initWithCoder:aDecoder]) ){
        // save this?
        _focusRect = CGRectMake(18, 326, 60, 60);
        
        // RRCaptureSession
        _captureSession = [[RRCaptureSession alloc] init];
        [_captureSession setDelegate:self];
    }
    return self;
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    // focus rect layer
    _focusRectLayer = [[CALayer alloc] init];
    [_focusRectLayer setHidden:YES];
    [_focusRectLayer setBorderColor: [UIColor grayColor].CGColor];
    [_focusRectLayer setBorderWidth: 1.0f];
    [_focusRectLayer setFrame:_focusRect];
    [self.view.layer insertSublayer:_focusRectLayer atIndex:0];

    // Preview
    [_captureSession.previewLayer setFrame: self.view.bounds];
    [self.view.layer insertSublayer:_captureSession.previewLayer atIndex:0];
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // Disable sleep
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    //    [AVCaptureDevice requestAccessForMediaType: AVMediaTypeVideo
    //                             completionHandler: ^(BOOL granted) {
    //                                 if ( !granted ) {
    //                                     // "AVCam doesn't have permission to use Camera, please change privacy settings"
    //                                 }
    //                             }];
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    // Reaenable sleep
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}


#pragma mark -
#pragma mark RRCaptureViewController


- (void)updateFocusRectFrame {
    CGPoint focusPoint = _captureSession.focusPointOfInterest;
    focusPoint.x *= CGRectGetWidth(_focusRectLayer.superlayer.frame);
    focusPoint.y *= CGRectGetHeight(_focusRectLayer.superlayer.frame);
    
    CGRect focusRect = _focusRect;
    focusRect.origin.x = focusPoint.x -CGRectGetWidth(focusRect)  /2.0f;
    focusRect.origin.y = focusPoint.y -CGRectGetHeight(focusRect) /2.0f;
    
    [_focusRectLayer setFrame: CGRectIntegral(focusRect)];
}


- (IBAction)focusTapGestureRecognized:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint tapLocation = [tapGestureRecognizer locationInView:self.view];
    [self refocusToLocationInView:tapLocation];
}


- (void)refocusToLocationInView:(CGPoint)point {
    point.x /= CGRectGetWidth(_focusRectLayer.superlayer.frame);
    point.y /= CGRectGetHeight(_focusRectLayer.superlayer.frame);
    
    [_captureSession focusWithMode: AVCaptureFocusModeAutoFocus
                    exposeWithMode: AVCaptureExposureModeAutoExpose
                           atPoint: point];
}


- (IBAction)switchRecordingState {
    
    if( self.isRunning ){
        [self stopRunning];
    }else{
        [self startRunning];
    }
    
}


- (void)captureFrame {
    
    // Animate
    [_actionButton setBackgroundColor: [UIColor redColor]];
    
    [UIView animateWithDuration: 0.31f
                     animations: ^{
                         [_actionButton setBackgroundColor: [UIColor lightGrayColor]];
                     }];
    
    NSTimeInterval timeIntervalSinceStart = ABS([_startTime timeIntervalSinceNow]);
    UIImage *frameImage = _captureSession.latestFrameImage;
    
    if( frameImage ){
        [self processFrameImage: frameImage
                   atTimeOffset: timeIntervalSinceStart];
    }
    
    if( timeIntervalSinceStart >= 120.0f ){
        [self stopRunning];
    }
    
}


- (BOOL)isRunning {
    return _captureSession.isRunning && _frameCaptureTimer;
}


- (void)startRunning {
    _startTime          = [NSDate date];
    _cachesPath         = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent: [_startTime description]];
#if TARGET_IPHONE_SIMULATOR
    _cachesPath         = @"/Users/GameBit/Desktop/RRPeeAnalizer/";
#endif
    _frameCaptureTimer  = [NSTimer scheduledTimerWithTimeInterval:1.0f target:self selector:@selector(captureFrame) userInfo:nil repeats:YES];

    NSError *createDirectoryError;
    [[NSFileManager defaultManager] createDirectoryAtPath: _cachesPath
                              withIntermediateDirectories: YES
                                               attributes: nil
                                                    error: &createDirectoryError];
    
    NSAssert1(!createDirectoryError, @"%@", createDirectoryError);
    
    [_actionButton setSelected:YES];
    [_focusRectLayer setHidden:NO];
    
    [_captureSession startRunning];

    [self refocusToLocationInView:CGPointMake(CGRectGetMidX(_focusRect), CGRectGetMidY(_focusRect))];
}


- (void)stopRunning {
    [_frameCaptureTimer invalidate], _frameCaptureTimer = nil;
    _startTime  = nil;
    _cachesPath = nil;
    
    [_actionButton setSelected:NO];
    [_focusRectLayer setHidden:YES];
    
    [_captureSession stopRunning];
}


- (void)processFrameImage:(UIImage *)frameImage atTimeOffset:(NSTimeInterval)timeOffset {
    NSAssert(frameImage, @"No frameImage");
    
    // find strip
    // crop image
    // calibrate ligh and colors
    // find squares
    // test colors
    // animate to squares
    
    // RRStripAnalyzer
    // RRStripAnalyzer *stripAnalyzer = [[RRStripAnalyzer alloc] initWithImage: frameImage];
    // CGRect bounds = [stripAnalyzer rectForStrip];
    
//    UIImage *lightCalibrationMask = [frameImage lightCalibrationMaskForRect:CGRectMake(10, 0, 10, frameImage.size.height)];
//    UIImage *lightCalibratedImage = [frameImage imageByApplyingLightCalibrationMask:lightCalibrationMask];
//    
//    [UIImageJPEGRepresentation(lightCalibratedImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%07.3fC.jpg", timeOffset]]
//                                                            atomically: YES];
    
    frameImage = [frameImage imageByAddingText: [NSString stringWithFormat:@"%f", timeOffset]
                                    atPosition: CGPointMake(10.0f, 10.0f)];
    
    [UIImageJPEGRepresentation(frameImage, 1.0f) writeToFile: [_cachesPath stringByAppendingPathComponent: [NSString stringWithFormat:@"%07.3f.jpg", timeOffset]]
                                                  atomically: YES];

}


#pragma mark -
#pragma mark RRCaptureSessionDelegate


- (void)captureSessionBeginAdjustingFocus:(RRCaptureSession *)captureSession {
    [_focusRectLayer setBorderColor: [UIColor grayColor].CGColor];
    
    [self updateFocusRectFrame];
}


- (void)captureSessionEndAdjustingFocus:(RRCaptureSession *)captureSession {
    [_focusRectLayer setBorderColor: [UIColor greenColor].CGColor];
    
    [self updateFocusRectFrame];
}


@end
