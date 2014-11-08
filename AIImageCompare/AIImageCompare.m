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
#include <tgmath.h>

static const NSUInteger BytesPerPixel = 4;

CGContextRef CreateRGBABitmapContext(CGImageRef inImage);

#if TARGET_OS_IPHONE
CGImageRef CGImageFromImage(AIImage* image) {
    return image.CGImage;
}
#else
CGImageRef CGImageFromImage(AIImage* image) {
    return [image CGImageForProposedRect:nil context:nil hints:nil];
}
#endif

CG_EXTERN CGFloat AIImageMeanAbosulteError(AIImage* image1, AIImage* image2) {
    NSCAssert(CGSizeEqualToSize(image1.size, image2.size), @"Images should have the same size");
#if TARGET_OS_IPHONE
    NSCAssert(image1.scale == image2.scale, @"Images should have the same scale");
#endif

    CGContextRef ctx1 = CreateRGBABitmapContext(CGImageFromImage(image1));
    CGContextRef ctx2 = CreateRGBABitmapContext(CGImageFromImage(image2));
    
    const UInt8* data1 = CGBitmapContextGetData(ctx1);
    const UInt8* data2 = CGBitmapContextGetData(ctx2);
    
    NSUInteger size = (NSUInteger)(CGBitmapContextGetWidth(ctx1) * CGBitmapContextGetHeight(ctx1)) * BytesPerPixel;
    
    CGFloat sum = 0;
    for (NSUInteger i = 0; i < size; i += 1) {
        CGFloat diff = (data2[i] - data1[i]) / 255.0;
        sum += fabs(diff);
    }
    
    CGContextRelease(ctx1);
    CGContextRelease(ctx2);
    
    return sum / (CGFloat)size;
}

CG_EXTERN CGFloat AIImageRootMeanSquareError(AIImage* image1, AIImage* image2) {
    NSCAssert(CGSizeEqualToSize(image1.size, image2.size), @"Images should have the same size");
    
    CGContextRef ctx1 = CreateRGBABitmapContext(CGImageFromImage(image1));
    CGContextRef ctx2 = CreateRGBABitmapContext(CGImageFromImage(image2));
    
    const UInt8* data1 = CGBitmapContextGetData(ctx1);
    const UInt8* data2 = CGBitmapContextGetData(ctx2);
    
    NSUInteger size = (NSUInteger)(CGBitmapContextGetWidth(ctx1) * CGBitmapContextGetHeight(ctx1)) * BytesPerPixel;
    
    CGFloat sum = 0;
    for (NSUInteger i = 0; i < size; i += 1) {
        CGFloat diff = (data2[i] - data1[i]) / 255.0;
        sum += diff*diff;
    }
    
    CGContextRelease(ctx1);
    CGContextRelease(ctx2);
    
    return sqrt(sum / (CGFloat)size);
}

CGContextRef CreateRGBABitmapContext(CGImageRef inImage) {
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    size_t bitmapBytesPerRow = pixelsWide * BytesPerPixel;
    
    // Use the generic RGB color space.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL)
        return NULL;
    
    // Create 32-bit RGBA context
    CGContextRef context = CGBitmapContextCreate(NULL,
                                                 pixelsWide,
                                                 pixelsHigh,
                                                 8, // bits per component
                                                 bitmapBytesPerRow,
                                                 colorSpace,
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    // Draw image in context
    CGRect rect = {{0, 0}, {pixelsWide, pixelsHigh}};
    CGContextDrawImage(context, rect, inImage);
    
    return context;
}
