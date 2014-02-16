#import "Capturer.h"
#import <AVFoundation/AVFoundation.h>

@interface Capturer()<AVCaptureVideoDataOutputSampleBufferDelegate>

@property(nonatomic, retain) AVCaptureSession* session;

@end

@implementation Capturer

- (void)configureInput {
	
	AVCaptureDevice* device= [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
	if(!device){
		return;
	}
	
	AVCaptureInput* input= [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
	if(!input){
		return;
	}
	[_session addInput:input];
	
//	[device lockForConfiguration:nil];
//	[device setActiveVideoMinFrameDuration:CMTimeMake(1, 15)];
//	[device setActiveVideoMaxFrameDuration:CMTimeMake(1, 15)];
//	[device unlockForConfiguration];
}

- (void)configureOutput {
	
	AVCaptureVideoDataOutput* output= [[AVCaptureVideoDataOutput new] autorelease];
	if(!output){
		return;
	}
	
	output.videoSettings= @{(id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_32BGRA]};
	[output setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
	[output setAlwaysDiscardsLateVideoFrames:YES];
	
	[_session addOutput:output];
}

- (UIImage *)imageWithBuffer:(CVImageBufferRef)buffer {
	
	CGColorSpaceRef colorSpace= CGColorSpaceCreateDeviceRGB();
	CGContextRef context= CGBitmapContextCreate(CVPixelBufferGetBaseAddress(buffer),
												CVPixelBufferGetWidth(buffer),
												CVPixelBufferGetHeight(buffer),
												8,
												CVPixelBufferGetBytesPerRow(buffer),
												colorSpace,
												kCGImageAlphaPremultipliedFirst|kCGBitmapByteOrder32Little);
	CGColorSpaceRelease(colorSpace);
	
	CGImageRef cgImage= CGBitmapContextCreateImage(context);
	UIImage* image= [[UIImage alloc] initWithCGImage:cgImage];
	
	CGContextRelease(context);
	CGImageRelease(cgImage);
	
	return [image autorelease];
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate methods

- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
	   fromConnection:(AVCaptureConnection *)connection {
	
	CVImageBufferRef buffer= CMSampleBufferGetImageBuffer(sampleBuffer);
	
//	CVPixelBufferLockBaseAddress(buffer, 0);
//	UIImage* image= [self imageWithBuffer:buffer];
//	CVPixelBufferUnlockBaseAddress(buffer, 0);
	
	[self.delegate pixelBufferReadyForDisplay:buffer];
}

#pragma mark -

- (void)start {
	
	if(self.session.running){
		return;
	}
	
	[self.session startRunning];
}

- (void)stop {
	
	if(!self.session.running){
		return;
	}
	
	[self.session stopRunning];
}

#pragma mark - NSObject methods

- (id)init {
	
	self = [super init];
	if (self) {
		
		_session= [AVCaptureSession new];
		_session.sessionPreset= AVCaptureSessionPreset1280x720;
		[_session beginConfiguration];
		[self configureInput];
		[self configureOutput];
		[_session commitConfiguration];
		
	}
	return self;
}

- (void)dealloc {
	
	[_session release];
	
	[super dealloc];
}

@end
