import {vec3} from 'gl-matrix';
import * as Stats from 'stats-js';
import * as DAT from 'dat-gui';
import Square from './geometry/Square';
import Mesh from './geometry/Mesh';
import OpenGLRenderer, {setBloomThresh, setDOF, setRadius, setLevel} from './rendering/gl/OpenGLRenderer';
import Camera from './Camera';
import {setGL} from './globals';
import {readTextFile} from './globals';
import ShaderProgram, {Shader} from './rendering/gl/ShaderProgram';
import Texture from './rendering/gl/Texture';



// mesh and texture
let square: Square;
let obj0: string;
let mesh0: Mesh;
let mesh1: Mesh;
let mesh2: Mesh;
let tex0: Texture;
let tex1: Texture;
let tex2: Texture;


const canvas = <HTMLCanvasElement> document.getElementById('canvas');

const controls = {
  Bloom : true,
  BloomThreshold : 0.5,
  DOF : true,
  DOFDistance : 30.0,
  OilPaint : false,
  Radius : 3,
  Sigma : 1,
};

let isBloom = true;
let isDOF = true;
let isOil = false;

var timer = {
  deltaTime: 0.0,
  startTime: 0.0,
  currentTime: 0.0,
  updateTime: function() {
    var t = Date.now();
    t = (t - timer.startTime) * 0.001;
    timer.deltaTime = t - timer.currentTime;
    timer.currentTime = t;
  },
}


function loadOBJText() {
  obj0 = readTextFile('../resources/obj/wahoo.obj')
}

function loadScene() {
  square && square.destroy();
  mesh0 && mesh0.destroy();
  mesh1 && mesh1.destroy();
  mesh2 && mesh2.destroy();

  square = new Square(vec3.fromValues(0, 0, 0));
  square.create();

  mesh0 = new Mesh(obj0, vec3.fromValues(0, -10, 0));
  mesh0.create();

  mesh1 = new Mesh(obj0, vec3.fromValues(0, -10, -10));
  mesh1.create();

  mesh2 = new Mesh(obj0, vec3.fromValues(0, -10, -20));
  mesh2.create();

  tex0 = new Texture('../resources/textures/wahoo.bmp')

}


function main() {
  // Initial display for framerate
  const stats = Stats();
  stats.setMode(0);
  stats.domElement.style.position = 'absolute';
  stats.domElement.style.left = '0px';
  stats.domElement.style.top = '0px';
  document.body.appendChild(stats.domElement);

  // get canvas and webgl context
  const gl = <WebGL2RenderingContext> canvas.getContext('webgl2');
  if (!gl) {
    alert('WebGL 2 not supported!');
  }
  // `setGL` is a function imported above which sets the value of `gl` in the `globals.ts` module.
  // Later, we can import `gl` from `globals.ts` to access it
  setGL(gl);

  const renderer = new OpenGLRenderer(canvas);

  // GUI
  const gui = new DAT.GUI();
  let bloom = gui.addFolder('Bloom');
  bloom.add(controls, 'Bloom', true).onChange(function() {
    isBloom = controls.Bloom;
  });
  bloom.add(controls, 'BloomThreshold', 0.0, 1.0).step(0.01).onChange(function() {
    setBloomThresh(controls.BloomThreshold);
  })

  let DOF = gui.addFolder('DOF');
  DOF.add(controls, 'DOF', true).onChange(function() {
    isDOF = controls.DOF;
  })
  DOF.add(controls, 'DOFDistance', 0.0, 100.0).onChange(function() {
    setDOF(controls.DOFDistance);
  })

  let Oil = gui.addFolder('Oil Painting');
  Oil.add(controls, 'OilPaint', false).onChange(function() {
    isOil = controls.OilPaint;
  })
  Oil.add(controls, 'Radius', 0.0, 5.0).step(0.1).onChange(function() {
    setRadius(controls.Radius);
  })
  Oil.add(controls, 'Sigma', 0.0, 10.0).step(0.5).onChange(function(){
    setLevel(controls.Sigma);
  })

  // Initial call to load scene
  loadScene();

  const camera = new Camera(vec3.fromValues(0, 0, 25), vec3.fromValues(0, 0, 0));

  
  renderer.setClearColor(0, 0, 0, 1);
  gl.enable(gl.DEPTH_TEST);

  const standardDeferred = new ShaderProgram([
    new Shader(gl.VERTEX_SHADER, require('./shaders/standard-vert.glsl')),
    new Shader(gl.FRAGMENT_SHADER, require('./shaders/standard-frag.glsl')),
    ]);

  standardDeferred.setupTexUnits(["tex_Color"]);

  function tick() {
    camera.update();
    stats.begin();
    gl.viewport(0, 0, window.innerWidth, window.innerHeight);
    timer.updateTime();
    renderer.updateTime(timer.deltaTime, timer.currentTime);

    standardDeferred.bindTexToUnit("tex_Color", tex0, 0);

    renderer.clear();
    renderer.clearGB();

    // TODO: pass any arguments you may need for shader passes
    // forward render mesh info into gbuffers
    renderer.renderToGBuffer(camera, standardDeferred, [mesh0, mesh1, mesh2]);
    // render from gbuffers into 32-bit color buffer
    renderer.renderFromGBuffer(camera);

    if(isBloom === true) {
      renderer.renderBloom();
    }
    
    if(isDOF === true) {
      renderer.renderDOF();
    }

    

    // apply 32-bit post and tonemap from 32-bit color to 8-bit color
    renderer.renderPostProcessHDR();
    // apply 8-bit post and draw

    if(isOil === true) {
      renderer.renderOilPaint();
    }

    renderer.renderPostProcessLDR();

    stats.end();
    requestAnimationFrame(tick);
  }

  window.addEventListener('resize', function() {
    renderer.setSize(window.innerWidth, window.innerHeight);
    camera.setAspectRatio(window.innerWidth / window.innerHeight);
    camera.updateProjectionMatrix();
  }, false);

  renderer.setSize(window.innerWidth, window.innerHeight);
  camera.setAspectRatio(window.innerWidth / window.innerHeight);
  camera.updateProjectionMatrix();


  // canvas.addEventListener("webglcontextlost", function(event) {
  //   event.preventDefault();
  // }, false);

  // Start the render loop
  tick();
}


function setup() {
  timer.startTime = Date.now();
  loadOBJText();
  main();
}

setup();

