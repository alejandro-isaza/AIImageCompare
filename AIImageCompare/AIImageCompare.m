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

static const NSUInteger kBytesPerPixel = 4;

static CGContextRef CreateRGBABitmapContext(CGImageRef inImage);

#if TARGET_OS_IPHONE
CGImageRef CGImageFromImage(AIImage* image) {
    return image.CGImage;
}
#else
CGImageRef CGImageFromImage(AIImage* image) {
    return [image CGImageForProposedRect:nil context:nil hints:nil];
}
#endif

CG_EXTERN NSUInteger AIImageForEachByte(AIImage* image1, AIImage* image2, void (^block)(UInt8 byte1, UInt8 byte2)) {
    CGImageRef cgimage1 = CGImageFromImage(image1);
    CGImageRef cgimage2 = CGImageFromImage(image2);

    NSCAssert(CGImageGetWidth(cgimage1) == CGImageGetWidth(cgimage2), @"Images should have the same size");
    NSCAssert(CGImageGetHeight(cgimage2) == CGImageGetHeight(cgimage2), @"Images should have the same size");

    CGContextRef ctx1 = CreateRGBABitmapContext(cgimage1);
    CGContextRef ctx2 = CreateRGBABitmapContext(cgimage2);

    const UInt8* data1 = CGBitmapContextGetData(ctx1);
    const UInt8* data2 = CGBitmapContextGetData(ctx2);

    NSUInteger pixelCount = (NSUInteger)(CGBitmapContextGetWidth(ctx1) * CGBitmapContextGetHeight(ctx1));
    NSUInteger byteCount = pixelCount * kBytesPerPixel;

    for (NSUInteger i = 0; i < byteCount; i += 1) {
        block(data1[i], data2[i]);
    }

    CGContextRelease(ctx1);
    CGContextRelease(ctx2);

    return byteCount;
}

CG_EXTERN NSUInteger AIImageForEachPixel(AIImage* image1, AIImage* image2, void (^block)(AIPixel pixel1, AIPixel pixel2)) {
    CGImageRef cgimage1 = CGImageFromImage(image1);
    CGImageRef cgimage2 = CGImageFromImage(image2);

    NSCAssert(CGImageGetWidth(cgimage1) == CGImageGetWidth(cgimage2), @"Images should have the same size");
    NSCAssert(CGImageGetHeight(cgimage2) == CGImageGetHeight(cgimage2), @"Images should have the same size");

    CGContextRef ctx1 = CreateRGBABitmapContext(cgimage1);
    CGContextRef ctx2 = CreateRGBABitmapContext(cgimage2);

    const UInt8* data1 = CGBitmapContextGetData(ctx1);
    const UInt8* data2 = CGBitmapContextGetData(ctx2);

    NSUInteger pixelCount = (NSUInteger)(CGBitmapContextGetWidth(ctx1) * CGBitmapContextGetHeight(ctx1));
    NSUInteger byteCount = pixelCount * kBytesPerPixel;

    for (NSUInteger i = 0; i < byteCount; i += kBytesPerPixel) {
        const AIPixel* pixel1 = (const AIPixel*)&data1[i];
        const AIPixel* pixel2 = (const AIPixel*)&data2[i];
        block(*pixel1, *pixel2);
    }

    CGContextRelease(ctx1);
    CGContextRelease(ctx2);

    return pixelCount;
}

CG_EXTERN CGFloat AIImageMeanAbsoluteError(AIImage* image1, AIImage* image2) {
    __block CGFloat sum = 0;

    NSUInteger byteCount = AIImageForEachByte(image1, image2, ^(UInt8 byte1, UInt8 byte2) {
        const CGFloat diff = (byte2 - byte1) / 255.0;
        sum += fabs(diff);
    });

    return sum / (CGFloat)byteCount;
}

CG_EXTERN AIComponents AIImageMeanAbsoluteErrorByComponent(AIImage* image1, AIImage* image2) {
    __block AIComponents components = {0, 0, 0, 0};

    NSUInteger pixelCount = AIImageForEachPixel(image1, image2, ^(AIPixel pixel1, AIPixel pixel2) {
        components.red   += fabs((pixel2.red - pixel1.red) / 255.0);
        components.green += fabs((pixel2.green - pixel1.green) / 255.0);
        components.blue  += fabs((pixel2.blue - pixel1.blue) / 255.0);
        components.alpha += fabs((pixel2.alpha - pixel1.alpha) / 255.0);
    });

    components.red   /= (CGFloat)pixelCount;
    components.green /= (CGFloat)pixelCount;
    components.blue  /= (CGFloat)pixelCount;
    components.alpha /= (CGFloat)pixelCount;

    return components;
}

CG_EXTERN CGFloat AIImageMaximumAbsoluteError(AIImage* image1, AIImage* image2) {
    __block CGFloat maxDiff = 0;

    AIImageForEachByte(image1, image2, ^(UInt8 byte1, UInt8 byte2) {
        const CGFloat diff = fabs((byte2 - byte1) / 255.0);
        if (diff > maxDiff)
            maxDiff = diff;
    });

    return maxDiff;
}

CG_EXTERN CGFloat AIImageRootMeanSquareError(AIImage* image1, AIImage* image2) {
    __block CGFloat sum = 0;

    NSUInteger byteCount = AIImageForEachByte(image1, image2, ^(UInt8 byte1, UInt8 byte2) {
        const CGFloat diff = (byte2 - byte1) / 255.0;
        sum += diff * diff;
    });

    return sqrt(sum / (CGFloat)byteCount);
}

CG_EXTERN NSUInteger AIImageDifferentPixelCount(AIImage* image1, AIImage* image2) {
    __block NSUInteger sum = 0;

    AIImageForEachPixel(image1, image2, ^(AIPixel pixel1, AIPixel pixel2) {
        const UInt32 value1 = *(const UInt32*)&pixel1;
        const UInt32 value2 = *(const UInt32*)&pixel2;
        if (value1 != value2)
            sum += 1;
    });

    return sum;
}

CG_EXTERN CGFloat AIImageDifferentPixelRatio(AIImage* image1, AIImage* image2) {
    CGImageRef image = CGImageFromImage(image1);
    size_t pixelsWide = CGImageGetWidth(image);
    size_t pixelsHigh = CGImageGetHeight(image);
    CGFloat pixelCount = AIImageDifferentPixelCount(image1, image2);
    return pixelCount / (pixelsWide * pixelsHigh);
}

static CGContextRef CreateRGBABitmapContext(CGImageRef inImage) {
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    size_t bitmapBytesPerRow = pixelsWide * kBytesPerPixel;
    
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
