#import <UIKit/UIKit.h>
#import "Capturer.h"

@interface CameraView : UIView<CapturerDelegate>

@property(nonatomic) float amplitude;
@property(nonatomic) float period;

- (void)setupGL;

@end
