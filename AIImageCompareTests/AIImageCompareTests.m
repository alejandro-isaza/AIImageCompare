// Copyright (c) 2014 Alejandro Isaza <al@isaza.ca>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy of
// this software and associated documentation files (the "Software"), to deal in
// the Software without restriction, including without limitation the rights to
// use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
// the Software, and to permit persons to whom the Software is furnished to do so,
// subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
// FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
// COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
// IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
// CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "AIImageCompare.h"
#import <XCTest/XCTest.h>

@interface AIImageCompareTests : XCTestCase

@end


@implementation AIImageCompareTests

- (UIImage*)testImageWithName:(NSString*)name {
    NSBundle* bundle = [NSBundle bundleForClass:[self class]];
    NSString* path = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}

- (void)testMeanAbsoluteErrorSame {
    UIImage* image = [self testImageWithName:@"1123"];
    CGFloat mae = AIImageMeanAbsoluteError(image, image);
    XCTAssertEqual(mae, 0, @"The MAE of an image with itself should be 0");
}

- (void)testMeanAbsoluteErrorDifferent {
    UIImage* image1 = [self testImageWithName:@"1123"];
    UIImage* image2 = [self testImageWithName:@"1124"];
    CGFloat mae = AIImageMeanAbsoluteError(image1, image2);
    XCTAssertEqualWithAccuracy(mae, 0.00012, 0.00001, @"The MAE of different images should be around 0.00012");
}

- (void)testRootMeanSquareErrorSame {
    UIImage* image = [self testImageWithName:@"1123"];
    CGFloat rmse = AIImageRootMeanSquareError(image, image);
    XCTAssertEqual(rmse, 0, @"The RMSE of an image with itself should be 0");
}

- (void)testRootMeanSquareErrorDifferent {
    UIImage* image1 = [self testImageWithName:@"1123"];
    UIImage* image2 = [self testImageWithName:@"1124"];
    CGFloat rmse = AIImageRootMeanSquareError(image1, image2);
    XCTAssertEqualWithAccuracy(rmse, 0.0097, 0.0001, @"The RMSE of different images should be around 0.00012");
}

@end
