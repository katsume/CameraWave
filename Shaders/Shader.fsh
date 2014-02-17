varying mediump vec2 texcoordVarying;

uniform sampler2D texture;
uniform mediump float amplitude;
uniform mediump float period;
uniform mediump float scale;
uniform mediump float phase;

const mediump float PI= 3.1415;

void main() {
	
	mediump float x= texcoordVarying.x+amplitude*sin(((texcoordVarying.y*PI)+phase)*2.0*period);
	mediump float y= texcoordVarying.y;
	
	x= 0.5+(x-0.5)/scale;
	y= 0.5+(y-0.5)/scale;
	
	if(x<0.0 || 1.0<=x || y<0.0 || 1.0<=y){
		gl_FragColor= vec4(0.0, 0.0, 0.0, 0.0);
	} else {
		gl_FragColor= texture2D(texture, vec2(x, y));
	}
}
