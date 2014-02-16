#import <Foundation/Foundation.h>

@protocol CapturerDelegate<NSObject>

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer;

@end

@interface Capturer : NSObject

@property(nonatomic, assign) id<CapturerDelegate> delegate;

- (void)start;
- (void)stop;

@end
