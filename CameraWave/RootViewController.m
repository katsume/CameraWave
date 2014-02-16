#import "RootViewController.h"
#import "Capturer.h"
#import "CameraView.h"

@interface RootViewController ()

@property(nonatomic, retain) Capturer* capturer;
@property(nonatomic) CameraView* cameraView;
@property(nonatomic) UIView* controlView;

@end

@implementation RootViewController

- (void)handleUpdateAmplitude:(id)sender {
	self.cameraView.amplitude= ((UISlider *)sender).value;
}

- (void)handleUpdatePeriod:(id)sender {
	self.cameraView.period= ((UISlider *)sender).value;
}

- (void)handleTap:(id)sender {
	self.controlView.hidden= !self.controlView.hidden;
}

#pragma mark - UIViewController methods

- (void)loadView {
	[super loadView];
	
	CGRect bounds= [[UIScreen mainScreen] bounds];
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && bounds.size.width < bounds.size.height){
		bounds.size= CGSizeMake(bounds.size.height, bounds.size.width);
	}
	self.view= [[[UIView alloc] initWithFrame:bounds] autorelease];
	
	self.cameraView= [[[CameraView alloc] initWithFrame:bounds] autorelease];
	[self.view addSubview:self.cameraView];
	
	self.controlView= [[[UIView alloc] initWithFrame:bounds] autorelease];
	[self.view addSubview:self.controlView];
	
	CGFloat sliderHeight= 50;
	CGFloat amplitudeSliderWidth= bounds.size.width-100;
	UISlider* amplitudeSlider= [[[UISlider alloc] initWithFrame:CGRectMake((bounds.size.width-amplitudeSliderWidth)/2,
																		   bounds.size.height-sliderHeight,
																		   amplitudeSliderWidth,
																		   sliderHeight)] autorelease];
	amplitudeSlider.minimumValue= 0.0;
	amplitudeSlider.maximumValue= 0.1;
	amplitudeSlider.value= self.cameraView.amplitude;
	[amplitudeSlider addTarget:self action:@selector(handleUpdateAmplitude:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:amplitudeSlider];
	
	CGFloat periodSliderWidth= bounds.size.height-100;
	UISlider* periodSlider= [[[UISlider alloc] initWithFrame:CGRectMake(-(periodSliderWidth-sliderHeight)/2,
																		(bounds.size.height-sliderHeight)/2,
																		periodSliderWidth,
																		sliderHeight)] autorelease];
	periodSlider.transform= CGAffineTransformMakeRotation(M_PI_2);
	periodSlider.minimumValue= 0.0;
	periodSlider.maximumValue= 10.0;
	periodSlider.value= self.cameraView.period;
	[periodSlider addTarget:self action:@selector(handleUpdatePeriod:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:periodSlider];
	
	UITapGestureRecognizer* tapGestureRecognizer;
	tapGestureRecognizer= [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
	[self.view addGestureRecognizer:tapGestureRecognizer];
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	self.capturer= [[Capturer new] autorelease];
	self.capturer.delegate= self.cameraView;
	
	[self.cameraView setupGL];	
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
}

- (void)viewDidAppear:(BOOL)animated {
	[super viewDidAppear:animated];
	
	[self.capturer start];
}

- (void)didReceiveMemoryWarning {
	
	[super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
	
	[self.capturer stop];
	
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
	
	[super viewDidDisappear:animated];
}

- (void)dealloc {

	[_capturer release];

	[super dealloc];
}

@end
