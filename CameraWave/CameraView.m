#import "CameraView.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

enum {
	UNIFORM_TEXTURE,
	NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

enum {
	ATTRIB_VERTEX,
	ATTRIB_TEXTUREPOSITON,
	NUM_ATTRIBUTES
};

float vertexs[] = {
	-1.0f,	1.0f,	0.0f,	//left top
	-1.0f,	-1.0f,	0.0f,	//left bottom
	1.0f,	1.0f,	0.0f,	//right top
	1.0f,	-1.0f,	0.0f,	//right bottom
};

float texcoords[] = {
	0.125f,	0.0f,	//left top
	0.125f,	1.0f,	//left bottom
	0.875f,	0.0f,	//right top
	0.875f,	1.0f,	//right bottom
};

@interface CameraView() {
	
	CVOpenGLESTextureCacheRef _textureCache;
	GLuint _program;
	GLuint _frameBuffer;
	GLuint _colorBuffer;
	
	int _renderBufferWidth;
	int _renderBufferHeight;
}

@property(nonatomic, retain) EAGLContext* context;

@end

@implementation CameraView

#pragma mark -

- (void)setupGL {
	
	[EAGLContext setCurrentContext:self.context];
	
	[self loadShaders];
	
	glGenFramebuffers(1, &_frameBuffer);
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
	
	glGenRenderbuffers(1, &_colorBuffer);
	glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
	
	[self.context renderbufferStorage:GL_RENDERBUFFER fromDrawable:(CAEAGLLayer *)self.layer];
	
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_renderBufferWidth);
	glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_renderBufferHeight);
	
	glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, _colorBuffer);
	if(glCheckFramebufferStatus(GL_FRAMEBUFFER) != GL_FRAMEBUFFER_COMPLETE) {
		NSLog(@"Failure with framebuffer generation");
	}
	
	//  Create a new CVOpenGLESTexture cache
	CVReturn err= CVOpenGLESTextureCacheCreate(kCFAllocatorDefault, NULL, self.context, NULL, &_textureCache);
	if (err) {
		NSLog(@"Error at CVOpenGLESTextureCacheCreate %d", err);
	}	

	glEnableVertexAttribArray(ATTRIB_VERTEX);
	glVertexAttribPointer(ATTRIB_VERTEX, 3, GL_FLOAT, GL_FALSE, 0, vertexs);
	
	glEnableVertexAttribArray(ATTRIB_TEXTUREPOSITON);
	glVertexAttribPointer(ATTRIB_TEXTUREPOSITON, 2, GL_FLOAT, GL_FALSE, 0, texcoords);
	
}

#pragma mark - CapturerDelegate methods

- (void)pixelBufferReadyForDisplay:(CVPixelBufferRef)pixelBuffer {
	
	GLint frameWidth= (GLint)CVPixelBufferGetWidth(pixelBuffer);
	GLint frameHeight= (GLint)CVPixelBufferGetHeight(pixelBuffer);
	CVOpenGLESTextureRef texture= NULL;
	CVReturn err = CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
																_textureCache,
																pixelBuffer,
																NULL,
																GL_TEXTURE_2D,
																GL_RGBA,
																frameWidth,
																frameHeight,
																GL_BGRA,
																GL_UNSIGNED_BYTE,
																0,
																&texture);
	
	
	if (!texture || err) {
		NSLog(@"CVOpenGLESTextureCacheCreateTextureFromImage failed (error: %d)", err);
		return;
	}
	
	glBindTexture(CVOpenGLESTextureGetTarget(texture), CVOpenGLESTextureGetName(texture));
	
	// Set texture parameters
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
	glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
	
	glBindFramebuffer(GL_FRAMEBUFFER, _frameBuffer);
	
	// Set the view port to the entire view
	glViewport(0, 0, _renderBufferWidth, _renderBufferHeight);
	
	// Render the object again with ES2
	
	glUseProgram(_program);
	
//	glUniformMatrix4fv(uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX], 1, 0, _modelViewProjectionMatrix.m);
//	glUniformMatrix3fv(uniforms[UNIFORM_NORMAL_MATRIX], 1, 0, _normalMatrix.m);
	
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
	glBindRenderbuffer(GL_RENDERBUFFER, _colorBuffer);
	[self.context presentRenderbuffer:GL_RENDERBUFFER];
	
	//
	
	glBindTexture(CVOpenGLESTextureGetTarget(texture), 0);
	CVOpenGLESTextureCacheFlush(_textureCache, 0);
	CFRelease(texture);
}

#pragma mark - UIView methods

+ (Class)layerClass {
	return [CAEAGLLayer class];
}

- (id)initWithFrame:(CGRect)frame {
	
	self = [super initWithFrame:frame];
	if (self) {
		
		self.contentScaleFactor= [[UIScreen mainScreen] scale];
		
		CAEAGLLayer* layer= (CAEAGLLayer *)self.layer;
		layer.opaque= YES;
		layer.drawableProperties= @{kEAGLDrawablePropertyRetainedBacking: [NSNumber numberWithBool:NO],
									kEAGLDrawablePropertyColorFormat: kEAGLColorFormatRGBA8};
		
		_context= [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
	}
	return self;
}

- (void)dealloc {
	
    if (_textureCache) {
        CFRelease(_textureCache);
    }
	
	if (_program) {
		glDeleteProgram(_program);
	}
	
	if (_frameBuffer) {
        glDeleteFramebuffers(1, &_frameBuffer);
    }
	
    if (_colorBuffer) {
        glDeleteRenderbuffers(1, &_colorBuffer);
    }
	
	[_context release];
	
	[super dealloc];
}

#pragma mark -  OpenGL ES 2 shader compilation

- (BOOL)loadShaders
{
	GLuint vertShader, fragShader;
	NSString *vertShaderPathname, *fragShaderPathname;
	
	// Create shader program.
	_program = glCreateProgram();
	
	// Create and compile vertex shader.
	vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
	if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname]) {
		NSLog(@"Failed to compile vertex shader");
		return NO;
	}
	
	// Create and compile fragment shader.
	fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname]) {
		NSLog(@"Failed to compile fragment shader");
		return NO;
	}
	
	// Attach vertex shader to program.
	glAttachShader(_program, vertShader);
	
	// Attach fragment shader to program.
	glAttachShader(_program, fragShader);
	
	// Bind attribute locations.
	// This needs to be done prior to linking.
	glBindAttribLocation(_program, ATTRIB_VERTEX, "position");
	glBindAttribLocation(_program, ATTRIB_TEXTUREPOSITON, "texcoord");
	
	// Link program.
	if (![self linkProgram:_program]) {
		NSLog(@"Failed to link program: %d", _program);
		
		if (vertShader) {
			glDeleteShader(vertShader);
			vertShader = 0;
		}
		if (fragShader) {
			glDeleteShader(fragShader);
			fragShader = 0;
		}
		if (_program) {
			glDeleteProgram(_program);
			_program = 0;
		}
		
		return NO;
	}
	
	// Get uniform locations.
	//	uniforms[UNIFORM_MODELVIEWPROJECTION_MATRIX] = glGetUniformLocation(_program, "modelViewProjectionMatrix");
	//	uniforms[UNIFORM_NORMAL_MATRIX] = glGetUniformLocation(_program, "normalMatrix");
	
	// Release vertex and fragment shaders.
	if (vertShader) {
		glDetachShader(_program, vertShader);
		glDeleteShader(vertShader);
	}
	if (fragShader) {
		glDetachShader(_program, fragShader);
		glDeleteShader(fragShader);
	}
	
	return YES;
}

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
	GLint status;
	const GLchar *source;
	
	source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
	if (!source) {
		NSLog(@"Failed to load vertex shader");
		return NO;
	}
	
	*shader = glCreateShader(type);
	glShaderSource(*shader, 1, &source, NULL);
	glCompileShader(*shader);
	
#if defined(DEBUG)
	GLint logLength;
	glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetShaderInfoLog(*shader, logLength, &logLength, log);
		NSLog(@"Shader compile log:\n%s", log);
		free(log);
	}
#endif
	
	glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
	if (status == 0) {
		glDeleteShader(*shader);
		return NO;
	}
	
	return YES;
}

- (BOOL)linkProgram:(GLuint)prog
{
	GLint status;
	glLinkProgram(prog);
	
#if defined(DEBUG)
	GLint logLength;
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program link log:\n%s", log);
		free(log);
	}
#endif
	
	glGetProgramiv(prog, GL_LINK_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}

- (BOOL)validateProgram:(GLuint)prog
{
	GLint logLength, status;
	
	glValidateProgram(prog);
	glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
	if (logLength > 0) {
		GLchar *log = (GLchar *)malloc(logLength);
		glGetProgramInfoLog(prog, logLength, &logLength, log);
		NSLog(@"Program validate log:\n%s", log);
		free(log);
	}
	
	glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
	if (status == 0) {
		return NO;
	}
	
	return YES;
}

@end
