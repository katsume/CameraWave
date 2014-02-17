#import "RootViewController.h"
#import "Capturer.h"
#import "CameraView.h"

@interface RootViewController ()

@property(nonatomic, retain) Capturer* capturer;
@property(nonatomic) CameraView* cameraView;
@property(nonatomic) UIView* controlView;

@end

@implementation RootViewController

- (void)loadAttributes {

	NSUserDefaults* defaults= [NSUserDefaults standardUserDefaults];
	self.cameraView.amplitude= [defaults floatForKey:@"amplitude"];
	self.cameraView.period= [defaults floatForKey:@"period"];
	self.cameraView.scale= [defaults floatForKey:@"scale"];
	self.cameraView.phase= [defaults floatForKey:@"phase"];
}

- (void)saveAttributes {

	NSUserDefaults* defaults= [NSUserDefaults standardUserDefaults];
	[defaults setFloat:self.cameraView.amplitude forKey:@"amplitude"];
	[defaults setFloat:self.cameraView.period forKey:@"period"];
	[defaults setFloat:self.cameraView.scale forKey:@"scale"];
	[defaults setFloat:self.cameraView.phase forKey:@"phase"];
	[defaults synchronize];
}

- (void)handleUpdateAmplitude:(id)sender {
	self.cameraView.amplitude= ((UISlider *)sender).value;
}

- (void)handleUpdatePeriod:(id)sender {
	self.cameraView.period= ((UISlider *)sender).value;
}

- (void)handleUpdateScale:(id)sender {
	self.cameraView.scale= ((UISlider *)sender).value;
}

- (void)handleUpdatePhase:(id)sender {
	self.cameraView.phase= ((UISlider *)sender).value;
}

- (void)handleTap:(id)sender {
	self.controlView.hidden= !self.controlView.hidden;
	[self saveAttributes];
}

- (void)loadControlView {
	
	CGRect bounds= self.view.bounds;
	CGFloat sliderHeight= 50;
	CGFloat horizontalSliderWidth= bounds.size.width-100;
	CGFloat verticalSliderHeight= bounds.size.height-100;
	
	UISlider* amplitudeSlider= [[[UISlider alloc] initWithFrame:CGRectMake((bounds.size.width-horizontalSliderWidth)/2,
																		   bounds.size.height-sliderHeight,
																		   horizontalSliderWidth,
																		   sliderHeight)] autorelease];
	amplitudeSlider.minimumValue= 0.0;
	amplitudeSlider.maximumValue= 0.1;
	amplitudeSlider.value= self.cameraView.amplitude;
	[amplitudeSlider addTarget:self action:@selector(handleUpdateAmplitude:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:amplitudeSlider];
	
	UILabel* amplitudeLabel= [[[UILabel alloc] initWithFrame:amplitudeSlider.bounds] autorelease];
	amplitudeLabel.text= @"Amplitude";
	amplitudeLabel.textColor= [UIColor whiteColor];
	amplitudeLabel.textAlignment= NSTextAlignmentCenter;
	[amplitudeSlider addSubview:amplitudeLabel];
	
	UISlider* periodSlider= [[[UISlider alloc] initWithFrame:CGRectMake(-(verticalSliderHeight-sliderHeight)/2,
																		(bounds.size.height-sliderHeight)/2,
																		verticalSliderHeight,
																		sliderHeight)] autorelease];
	periodSlider.transform= CGAffineTransformMakeRotation(M_PI_2);
	periodSlider.minimumValue= 0.0;
	periodSlider.maximumValue= 10.0;
	periodSlider.value= self.cameraView.period;
	[periodSlider addTarget:self action:@selector(handleUpdatePeriod:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:periodSlider];
	
	UILabel* periodLabel= [[[UILabel alloc] initWithFrame:periodSlider.bounds] autorelease];
	periodLabel.text= @"Period";
	periodLabel.textColor= [UIColor whiteColor];
	periodLabel.textAlignment= NSTextAlignmentCenter;
	[periodSlider addSubview:periodLabel];
	
	UISlider* scaleSlider= [[[UISlider alloc] initWithFrame:CGRectMake((bounds.size.width-horizontalSliderWidth)/2,
																	   0,
																	   horizontalSliderWidth,
																	   sliderHeight)] autorelease];
	scaleSlider.minimumValue= 0.0;
	scaleSlider.maximumValue= 2.0;
	scaleSlider.value= self.cameraView.scale;
	[scaleSlider addTarget:self action:@selector(handleUpdateScale:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:scaleSlider];
	
	UILabel* scaleLabel= [[[UILabel alloc] initWithFrame:scaleSlider.bounds] autorelease];
	scaleLabel.text= @"Scale";
	scaleLabel.textColor= [UIColor whiteColor];
	scaleLabel.textAlignment= NSTextAlignmentCenter;
	[scaleSlider addSubview:scaleLabel];
	
	UISlider* phaseSlider= [[[UISlider alloc] initWithFrame:CGRectMake(bounds.size.width-sliderHeight-(verticalSliderHeight-sliderHeight)/2,
																		(bounds.size.height-sliderHeight)/2,
																		verticalSliderHeight,
																		sliderHeight)] autorelease];
	phaseSlider.transform= CGAffineTransformMakeRotation(-M_PI_2);
	phaseSlider.minimumValue= 0.0;
	phaseSlider.maximumValue= M_PI;
	phaseSlider.value= self.cameraView.phase;
	[phaseSlider addTarget:self action:@selector(handleUpdatePhase:) forControlEvents:UIControlEventValueChanged];
	[self.controlView addSubview:phaseSlider];
	
	UILabel* phaseLabel= [[[UILabel alloc] initWithFrame:phaseSlider.bounds] autorelease];
	phaseLabel.text= @"Phase";
	phaseLabel.textColor= [UIColor whiteColor];
	phaseLabel.textAlignment= NSTextAlignmentCenter;
	[phaseSlider addSubview:phaseLabel];
	
	UITapGestureRecognizer* tapGestureRecognizer;
	tapGestureRecognizer= [[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)] autorelease];
	[self.view addGestureRecognizer:tapGestureRecognizer];
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
}

- (void)viewDidLoad {
	[super viewDidLoad];
	
	[self loadAttributes];
	[self loadControlView];

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
