import Texture from './Texture';
import {gl} from '../../globals';
import ShaderProgram, {Shader} from './ShaderProgram';
import Drawable from './Drawable';
import Square from '../../geometry/Square';
import {vec2, vec3, vec4, mat4} from 'gl-matrix';

class PostProcess extends ShaderProgram {
	static screenQuad: Square = undefined; // Quadrangle onto which we draw the frame texture of the last render pass
	unifFrame: WebGLUniformLocation; // The handle of a sampler2D in our shader which samples the texture drawn to the quad
	unifFrame2 : WebGLUniformLocation;
	unifDOF : WebGLUniformLocation;
	unifRad : WebGLUniformLocation;
	unifLevel : WebGLUniformLocation;

	name: string;

	constructor(fragProg: Shader, tag: string = "default") {
		super([new Shader(gl.VERTEX_SHADER, require('../../shaders/screenspace-vert.glsl')),
			fragProg]);

		this.unifFrame = gl.getUniformLocation(this.prog, "u_frame");
		this.unifFrame2 = gl.getUniformLocation(this.prog, "u_frame2");
		this.unifDOF = gl.getUniformLocation(this.prog, "u_DOF");
		this.unifRad = gl.getUniformLocation(this.prog, "u_Radius");
		this.unifLevel = gl.getUniformLocation(this.prog, "u_Level");

		this.use();
		this.name = tag;

		// bind texture unit 0 to this location
		gl.uniform1i(this.unifFrame, 0); // gl.TEXTURE0
		gl.uniform1i(this.unifFrame2, 1); // gl.TEXTURE1

		if (PostProcess.screenQuad === undefined) {
			PostProcess.screenQuad = new Square(vec3.fromValues(0, 0, 0));
			PostProcess.screenQuad.create();
		}
	}

  	draw() {
  		super.draw(PostProcess.screenQuad);
	}
	  

	getName() : string { return this.name; }
	  
	setDOF(d : number) {
		this.use();
		if (this.unifDOF !== null) {
			gl.uniform1f(this.unifDOF, d);
		}
	}

	setRadius(d : number) {
		this.use();
		if (this.unifRad !== null) {
			gl.uniform1f(this.unifRad, d);
		}
	}

	setLevel(d : number) {
		this.use();
		if (this.unifLevel !== null) {
			gl.uniform1f(this.unifLevel, d);
		}
	}

}

export default PostProcess;
