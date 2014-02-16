#import "RootViewController.h"
#import "Capturer.h"
#import "CameraView.h"

@interface RootViewController ()

@property(nonatomic, retain) Capturer* capturer;
@property(nonatomic) CameraView* cameraView;

@end

@implementation RootViewController

#pragma mark - UIViewController methods

- (void)loadView {
	[super loadView];
	
	CGRect bounds= [[UIScreen mainScreen] bounds];
	if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && bounds.size.width < bounds.size.height){
		bounds.size= CGSizeMake(bounds.size.height, bounds.size.width);
	}
	self.view= [[[UIView alloc] initWithFrame:bounds] autorelease];
	
	self.cameraView= [[[CameraView alloc] initWithFrame:self.view.bounds] autorelease];
	[self.view addSubview:self.cameraView];
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
