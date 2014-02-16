#import <UIKit/UIKit.h>
#import "Capturer.h"

@interface CameraView : UIView<CapturerDelegate>

- (void)setupGL;

@end
