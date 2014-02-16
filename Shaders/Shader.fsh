varying mediump vec2 texcoordVarying;
uniform mediump float amplitude;
uniform mediump float period;
uniform sampler2D texture;

const mediump float PI= 3.1415;

void main() {
	
	mediump float x= texcoordVarying.x+amplitude*sin(texcoordVarying.y*PI*2.0*period);
	mediump float y= texcoordVarying.y;
	
	x= 0.5+(x-0.5)/0.8;
	y= 0.5+(y-0.5)/0.8;
	
	if(x<0.0 || 1.0<=x || y<0.0 || 1.0<=y){
		gl_FragColor= vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor= texture2D(texture, vec2(x, y));
	}
}
