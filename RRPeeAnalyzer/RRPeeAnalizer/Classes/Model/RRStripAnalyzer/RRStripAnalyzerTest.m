//
//  RRStripAnalyzerTest.m
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

#import "RRStripAnalyzerTest.h"


@implementation RRStripAnalyzerTest


#pragma mark -
#pragma mark NSCoding


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.color     forKey:@"color"];
    [aCoder encodeObject:self.type      forKey:@"type"];
    [aCoder encodeObject:self.value     forKey:@"value"];
    [aCoder encodeCGRect:self.rect      forKey:@"rect"];
    [aCoder encodeFloat:self.plotValue  forKey:@"plotValue"];
}


- (id)initWithCoder:(NSCoder *)aDecoder {
    if( (self = [super init]) ){
        [self setColor:     [aDecoder decodeObjectForKey:@"color"]];
        [self setType:      [aDecoder decodeObjectForKey:@"type"]];
        [self setValue:     [aDecoder decodeObjectForKey:@"value"]];
        [self setRect:      [aDecoder decodeCGRectForKey:@"rect"]];
        [self setPlotValue: [aDecoder decodeFloatForKey:@"plotValue"]];
    }
    return self;
}


#pragma mark -
#pragma mark NSObject


- (NSString *)description {
    return [NSString stringWithFormat:@"<RRStripAnalyzerTest %p %@ %@", self, self.type, self.value];
}


#pragma mark -
#pragma mark NSObject


- (id)copyWithZone:(NSZone *)zone {
    RRStripAnalyzerTest *stripAnalyzerTest = [[RRStripAnalyzerTest alloc] init];
    [stripAnalyzerTest setColor: self.color];
    [stripAnalyzerTest  setRect: self.rect];
    [stripAnalyzerTest  setType: self.type];
    [stripAnalyzerTest setValue: self.value];
    [stripAnalyzerTest setPlotValue: self.plotValue];

    return stripAnalyzerTest;
}


#pragma mark -
#pragma mark RRStripAnalyzerTest


- (BOOL)isSameRowAsTest:(RRStripAnalyzerTest *)stripAnalyzerTest {
    if( !stripAnalyzerTest ) return NO;
    
    CGRect myRect = CGRectMake(0, CGRectGetMinY(self.rect), CGFLOAT_MAX, CGRectGetHeight(self.rect));
    CGRect otherRect = CGRectMake(0, CGRectGetMinY(stripAnalyzerTest.rect), CGFLOAT_MAX, CGRectGetHeight(stripAnalyzerTest.rect));
    
    return CGRectIntersectsRect(myRect, otherRect);
}


@end
