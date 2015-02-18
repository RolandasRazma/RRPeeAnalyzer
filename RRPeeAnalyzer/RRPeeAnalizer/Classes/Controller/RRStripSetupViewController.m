//
//  RRStripSetupViewController.m
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

#import "RRStripSetupViewController.h"
#import "RRStripAnalyzer.h"
#import "RRStripAnalyzerTest.h"
#import "UIImage+UIColorAdditions.h"
#import "RRTestColorSetupViewController.h"
#import "FPPopoverController.h"


@interface RRStripSetupViewController () <FPPopoverControllerDelegate>

@end


@implementation RRStripSetupViewController {
    __weak IBOutlet UIScrollView    *_imageScrollView;
    __weak IBOutlet UIImageView     *_testImageView;
    
    FPPopoverController             *_popoverController;
    RRTestColorSetupViewController  *_testColorSetupViewController;
    CGRect                          _testColorRect;
    
    NSMutableArray                  *_stripAnalyzerTests;
}


#pragma mark -
#pragma mark NSCoder


- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if ( (self = [super initWithCoder:aDecoder]) ){
        _stripAnalyzerTests = [NSMutableArray array];
        
        NSMutableArray  *tests;
#if TARGET_IPHONE_SIMULATOR
        tests = (([NSKeyedUnarchiver unarchiveObjectWithFile:@"/Users/GameBit/Desktop/RRPeeAnalizer/DUS10.plist"])?:[NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DUS10" ofType:@"plist"]]);
#else
        tests = [NSKeyedUnarchiver unarchiveObjectWithFile:[[NSBundle mainBundle] pathForResource:@"DUS10" ofType:@"plist"]];
#endif

        for( NSMutableArray *row in tests ){
            [_stripAnalyzerTests addObjectsFromArray:row];
        }
    }
    return self;
}


#pragma mark -
#pragma mark UIViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_imageScrollView setZoomScale:0.5f];
    
    for( RRStripAnalyzerTest *stripAnalyzerTest in _stripAnalyzerTests ){
        CALayer *rectLayer = [[CALayer alloc] init];
        [rectLayer setBorderColor: [UIColor greenColor].CGColor];
        [rectLayer setBackgroundColor: stripAnalyzerTest.color.CGColor];
        [rectLayer setBorderWidth: 1.0f];
        [rectLayer setFrame:stripAnalyzerTest.rect];
        [_testImageView.layer addSublayer:rectLayer];
        
        CATextLayer *textLayer = [[CATextLayer alloc] init];
        [textLayer setAlignmentMode:@"center"];
        [textLayer setFrame:rectLayer.bounds];
        [textLayer setString: [NSString stringWithFormat:@"%@\n%@\n(%.3f)", stripAnalyzerTest.type, stripAnalyzerTest.value, stripAnalyzerTest.plotValue]];
        [textLayer setFontSize:12];
        [rectLayer addSublayer:textLayer];
    }
}


#pragma mark -
#pragma mark RRStripSetupViewController


- (IBAction)longPressGestureRecognizerd:(UILongPressGestureRecognizer *)longPressGestureRecognizer {
    if ( longPressGestureRecognizer.state != UIGestureRecognizerStateBegan ) return;
    
    CGRect rect = [RRStripAnalyzer rectInImage: _testImageView.image
                                       atPoint: [longPressGestureRecognizer locationInView:_testImageView]];

    if( !CGRectIsNull(rect) && rect.size.width <= 100.0f ){
        // inset rect to compensate for possible detection mistakes
        CGRect rectForColor = CGRectIntegral(CGRectInset(rect, CGRectGetWidth(rect) *0.10f, CGRectGetHeight(rect) *0.10f));
        
        UIColor *color = [_testImageView.image dominantColorForRect: rectForColor];
        
        CALayer *rectLayer = [[CALayer alloc] init];
        [rectLayer setBorderColor: [UIColor greenColor].CGColor];
        [rectLayer setBackgroundColor: color.CGColor];
        [rectLayer setBorderWidth: 1.0f];
        [rectLayer setFrame:rect];
        [_testImageView.layer addSublayer:rectLayer];
        
        // Show setup
        _testColorRect = rect;
        
        UINavigationController *testColorSetupStack = [self.storyboard instantiateViewControllerWithIdentifier:@"RRTestColorSetupStack"];
        [testColorSetupStack.view setClipsToBounds:YES];

        RRStripAnalyzerTest *stripAnalyzerTest = [self testForRect:_testColorRect];
        
        _testColorSetupViewController = testColorSetupStack.viewControllers[0];
        [_testColorSetupViewController setColor:color];
        [_testColorSetupViewController setTestType: [self testTypeForRect:_testColorRect]];
        [_testColorSetupViewController setTestValue: stripAnalyzerTest.value];
        [_testColorSetupViewController setTestPlotValue: stripAnalyzerTest.plotValue];

        // FPPopoverController
        _popoverController = [[FPPopoverController alloc] initWithViewController:testColorSetupStack];
        [_popoverController setDelegate:self];
        [_popoverController presentPopoverFromPoint: [_testImageView convertPoint:CGPointMake(CGRectGetMidX(rectForColor), CGRectGetMidY(rectForColor)) toView:nil]];

    }
    
}


- (NSString *)testTypeForRect:(CGRect)testRect {
    testRect.origin.x   = 0.0f;
    testRect.size.width = CGFLOAT_MAX;
    
    for( RRStripAnalyzerTest *test in _stripAnalyzerTests ){
        if( CGRectIntersectsRect(test.rect, testRect) ){
            return test.type;
        }
    }
    
    return nil;
}


- (RRStripAnalyzerTest *)testForRect:(CGRect)testRect {
    for( RRStripAnalyzerTest *test in _stripAnalyzerTests ){
        if( CGRectIntersectsRect(test.rect, testRect) ){
            return test;
        }
    }
    return nil;
}


- (void)saveTestToFile:(NSString *)filePath {
    
    NSMutableArray *tests = [_stripAnalyzerTests mutableCopy];
    
    #define COMPARE(__A__, __B__) (( __A__ == __B__ )?NSOrderedSame:(( __A__ < __B__ )?NSOrderedAscending:NSOrderedDescending))

    // Sort on Y
    [tests sortUsingComparator:^NSComparisonResult(RRStripAnalyzerTest *stripAnalyzerTestA, RRStripAnalyzerTest *stripAnalyzerTestB) {
        return COMPARE( stripAnalyzerTestA.rect.origin.y, stripAnalyzerTestB.rect.origin.y );
    }];
    
    NSMutableArray *allRows = [NSMutableArray array];
    
    // Split into rows
    RRStripAnalyzerTest *lastTest;
    int rowIndex = -1;
    NSMutableArray *testRow;
    for( RRStripAnalyzerTest *test in tests ){
        if( ![test isSameRowAsTest:lastTest] ){
            rowIndex++;
            testRow = [NSMutableArray array];
            [allRows addObject:testRow];
        }
        
        [testRow addObject: test];

        lastTest = test;
    }

    // Sort rows
    for( NSMutableArray *testRow in allRows ){
        [testRow sortUsingComparator:^NSComparisonResult(RRStripAnalyzerTest *stripAnalyzerTestA, RRStripAnalyzerTest *stripAnalyzerTestB) {
            return COMPARE( stripAnalyzerTestA.plotValue, stripAnalyzerTestB.plotValue );
        }];
    }
    
    // Save
    [[NSKeyedArchiver archivedDataWithRootObject:allRows] writeToFile:filePath atomically:YES];
}


#pragma mark -
#pragma mark UIScrollViewDelegate


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _testImageView;
}


#pragma mark -
#pragma mark FPPopoverControllerDelegate


- (void)popoverControllerDidDismissPopover:(FPPopoverController *)popoverController {

    RRStripAnalyzerTest *stripAnalyzerTest = [self testForRect:_testColorRect];
    if( !stripAnalyzerTest ){
        stripAnalyzerTest = [[RRStripAnalyzerTest alloc] init];
        [_stripAnalyzerTests addObject:stripAnalyzerTest];
    }
    
    [stripAnalyzerTest setType: _testColorSetupViewController.testType];
    [stripAnalyzerTest setRect: _testColorRect];
    [stripAnalyzerTest setValue: ((_testColorSetupViewController.testValue.length)?_testColorSetupViewController.testValue:[NSString stringWithFormat:@"%.3f", _testColorSetupViewController.testPlotValue])];
    [stripAnalyzerTest setPlotValue: _testColorSetupViewController.testPlotValue];
    [stripAnalyzerTest setColor: _testColorSetupViewController.view.backgroundColor];

    // cleanup
    _testColorSetupViewController   = nil;
    _popoverController              = nil;
    _testColorRect                  = CGRectNull;

#if TARGET_IPHONE_SIMULATOR
    [self saveTestToFile:@"/Users/GameBit/Desktop/RRPeeAnalizer/DUS10.plist"];
#endif
    
}


@end
