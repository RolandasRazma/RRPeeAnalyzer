//
//  RRCaptureSession.m
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

#import "RRCaptureSession.h"


@interface RRCaptureSession () <AVCaptureVideoDataOutputSampleBufferDelegate>

@end


@implementation RRCaptureSession {
    __weak id <RRCaptureSessionDelegate> _delegate;
    
    AVCaptureSession        *_captureSession;
    CALayer                 *_previewLayer;
    AVCaptureDeviceInput    *_captureDeviceInput;
    
    dispatch_queue_t        _captureSessionDispatchQueue;
    
    CGImageRef              _latestFrameImageRef;
    
    CGPoint                 _focusPoint;
}


#pragma mark -
#pragma mark NSObject


- (void)dealloc {
    [_captureDeviceInput.device removeObserver:self forKeyPath:@"adjustingFocus"];
}


- (id)init {
    if( (self = [super init]) ){
        _captureSessionDispatchQueue = dispatch_queue_create("-[RRCaptureSession captureSessionDispatchQueue]", DISPATCH_QUEUE_SERIAL);
        _focusPoint = CGPointMake(0.5f, 0.5f);

#if TARGET_IPHONE_SIMULATOR
        _previewLayer = [[CALayer alloc] init];
        [_previewLayer setHidden:YES];
        [_previewLayer setContents: (id)[UIImage imageNamed:@"RRCaptureSessionStill.jpg"].CGImage];
        [_previewLayer setContentsGravity:@"resizeAspectFill"];
#else
        AVCaptureDevice *captureDevice  = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        
        _captureDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:nil];
        [_captureDeviceInput.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:NULL];

        AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
        [output setAlwaysDiscardsLateVideoFrames: YES];
        
        dispatch_queue_t dispatchQueue;
        dispatchQueue = dispatch_queue_create("-[RRCaptureSession queue]", NULL);
        
        [output setSampleBufferDelegate:self queue:dispatchQueue];
        [output setVideoSettings:@{ (NSString *)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_32BGRA) }];
        
        _captureSession = [[AVCaptureSession alloc] init];
        [_captureSession addInput:_captureDeviceInput];
        [_captureSession addOutput:output];
        [_captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
#endif
    }
    return self;
}


#pragma mark -
#pragma mark RRCaptureSession


- (void)startRunning {
    [_previewLayer setHidden:NO];
    [_captureSession startRunning];
}


- (void)stopRunning {
    [_captureSession stopRunning];
    [_previewLayer setHidden:YES];
    [self setLatestFrameImageRef: nil];
}


- (UIImage *)latestFrameImage {
    @synchronized( self ){
#if TARGET_IPHONE_SIMULATOR
        return [[UIImage imageWithCGImage: (CGImageRef)_previewLayer.contents] copy];
#else
        return ((_latestFrameImageRef)?[[UIImage imageWithCGImage:_latestFrameImageRef scale:1.0f orientation:UIImageOrientationRight] copy]:nil);
#endif
    }
}


- (void)setLatestFrameImageRef:(CGImageRef)latestFrameImageRef {
    @synchronized( self ){
        if( _latestFrameImageRef ){
            CGImageRelease(_latestFrameImageRef);
        }
        _latestFrameImageRef = latestFrameImageRef;
    }
}


- (CALayer *)previewLayer {
    if( !_previewLayer && _captureSession ){
        _previewLayer = [AVCaptureVideoPreviewLayer layerWithSession:_captureSession];
        [(AVCaptureVideoPreviewLayer *)_previewLayer setVideoGravity: AVLayerVideoGravityResizeAspectFill];
    }
    return _previewLayer;
}


- (CGPoint)focusPointOfInterest {
#if TARGET_IPHONE_SIMULATOR
    return _focusPoint;
#else
    AVCaptureDevice *device = [_captureDeviceInput device];
    return device.focusPointOfInterest;
#endif
}


- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atPoint:(CGPoint)point {
    _focusPoint = point;
    
#if TARGET_IPHONE_SIMULATOR
    [self observeValueForKeyPath:@"adjustingFocus" ofObject:nil change:nil context:NULL];
    return;
#else
    dispatch_async(_captureSessionDispatchQueue, ^{
        AVCaptureDevice *device = [_captureDeviceInput device];
        NSError *error = nil;
        if ( [device lockForConfiguration:&error] ) {
            
            if ( [device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode] ) {
                [device setFocusPointOfInterest:point];
                [device setFocusMode:focusMode];
            }
            
            if ( [device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode] ) {
                [device setExposurePointOfInterest:point];
                [device setExposureMode:exposureMode];
            }
            
            [device setSubjectAreaChangeMonitoringEnabled: NO];
            [device unlockForConfiguration];
        } else {
            NSLog(@"%@", error);
        }
    });
#endif
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {

    if( [keyPath isEqualToString:@"adjustingFocus"] ){
        AVCaptureDevice *captureDevice = object;
        
        if( captureDevice.isAdjustingFocus ){
            if( [_delegate respondsToSelector:@selector(captureSessionBeginAdjustingFocus:)] ){
                [_delegate captureSessionBeginAdjustingFocus:self];
            }
        }else{
            if( [_delegate respondsToSelector:@selector(captureSessionEndAdjustingFocus:)] ){
                [_delegate captureSessionEndAdjustingFocus:self];
            }
        }
    }
    
}


- (BOOL)isRunning {
#if TARGET_IPHONE_SIMULATOR
    return !_previewLayer.hidden;
#endif
    return _captureSession.isRunning;
}


#pragma mark -
#pragma mark AVCaptureVideoDataOutputSampleBufferDelegate


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width  = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);

    [self setLatestFrameImageRef: CGBitmapContextCreateImage(newContext)];
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    CVPixelBufferUnlockBaseAddress(imageBuffer, 0);

}


@end
