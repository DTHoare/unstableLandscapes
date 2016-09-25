/* -----------------------------------------------------------------------------
unstableLandscapes.pde
Daniel Hoare 2016

3D terrain generation, with animated water and first person camera
----------------------------------------------------------------------------- */

/* -----------------------------------------------------------------------------
Globals
----------------------------------------------------------------------------- */ 
import java.util.*;
Landscape3D landscape3D;
Landscape3D water;
Landscape3D waterfallLeft;
Landscape3D waterfallRight;
Camera cam;

//initial parameters for drawing
float angle = 0;
float waterHeight = 3;
int fps = 30;
boolean highRes = false;

//saving parameters
boolean save = false;
int frames = 0;

//colours
color skyBlue = color(135,206,250);
color waterBlue = color(70,90,220);
color grass = color(10,149,84);
color grassFar = color(30,169,134);
color grassFar2 = color(50,199,164);
color sand = color(239,221,111);
color redSand = color(190,70,18);

/* -----------------------------------------------------------------------------
Setup
----------------------------------------------------------------------------- */ 
void setup() {
  size(540,540, P3D);
  frameRate(fps); 
  
  //ortho for looking at cube world, use perspective for first person camera
  //ortho();
  //increase fov, and allow to see closer
  float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  //based upon default values, with wider FOV, and able to see objets closer to the camera
  perspective(PI/2.0, width/height, cameraZ/1000.0, cameraZ*10.0);
  
  //initial parameters of the first person camera
  PVector position= new PVector(0,80, 0);
  PVector direction = new PVector(0,8,0);
  cam = new Camera(position, direction);
  
  //use a power of 2 + 1 for midpoint algorithm
  int landscapeN = (int)pow(2,10) + 1;
  float landscapeSize = 257;
  
  //create a new landscape3D for terrain slightly smaller than water
  landscape3D = new Landscape3D(landscapeN,(landscapeSize-2*waterHeight)/float(landscapeN), redSand, 0);
  landscape3D.createPlane(0);
  //generate terrain, and centre for water level
  landscape3D.midPointDisplacement(200,0.45);
  landscape3D.centrePlane();
  landscape3D.box = true;
  
  //generate a water plane, and two water falls for the cube world
  water = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  water.createPlane(waterHeight);
  water.box = false;
  water.shiny = 3.0;
  
  waterfallLeft = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallLeft.createPlane(waterHeight);
  waterfallLeft.box = false;
  waterfallLeft.shiny = 4.0;
  
  waterfallRight = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallRight.createPlane(waterHeight);
  waterfallRight.box = false;
  waterfallRight.shiny = 4.0;
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  background(0);
  
  //camera
  cam.move();
  cam.moveWithMouse();
  cam.firstPersonViewFlying();
  
  //lighting does not revolve
  pushMatrix();
    isometricView(0);
    drawSun(0,150,5);
    sunsetGeneral(0,-7, -1); 
  popMatrix();
  
  //draw landscape, revolves with arrow keys
  pushMatrix();
    isometricView(angle);
    drawTerrain();
  popMatrix();

  //Water does not revolve
  pushMatrix();
    isometricView(0);
    //replace lights with sunset refletions off water
    noLights();
    sunsetWater(0,-7, -1);
  
    drawWater();
    //drawWaterfallLeft();
    //drawWaterfallRight();  
  popMatrix();

  //saving frames for gifs
  if(save && frames <30) {
    saveFrame(frames + ".png");
    frames++;
  } else if(save) {
    save = false;
    frames = 0;
  }
  
}
/* -----------------------------------------------------------------------------
landScapes
----------------------------------------------------------------------------- */
void drawTerrain() {
  landscape3D.displayMesh();
}

void drawWater() {
  //wave functions add to existing position, so position gets reset each frame
  water.setPreviousPosition();
  //water.radialWaves(1, 25, 5, 2, 0);
  //water.radialWaves(2, 35,  13, 1, 100);
  water.yWaves(1, 25, 9, 2, 0);
  water.yWaves(2, 35,  15, 1, 150);
  //chamfer edges gives smooth boundary for waterfalls
  //water.chamferEdges(40, waterHeight);
  water.displayMesh();
}

//waterfall left must be called immediately after drawWater() to position correctly
void drawWaterfallLeft() {
  translate(0, floor(waterfallLeft.size/2),0);
  rotateX(-PI/2);
  translate(0, floor(waterfallLeft.size/2),0);
  waterfallLeft.setPreviousPosition();
  waterfallLeft.waterfallRipple(4,90,3,0);
  waterfallLeft.waterfallRipple(7,55,5,100);
  waterfallLeft.waterfallRipple(2,75,2,54530);
  waterfallLeft.chamferEdges(40, waterHeight);
  waterfallLeft.displayMesh();
}

//waterfall right must be called immediately after drawWaterfallLeft() to position correctly
void drawWaterfallRight() {
  translate(floor(waterfallLeft.size/2),0,0);
  translate(0, 0, -floor(waterfallLeft.size/2));
  rotateY(PI/2);
  waterfallRight.setPreviousPosition();
  waterfallRight.waterfallRipple(4,80,3,0);
  waterfallRight.waterfallRipple(3,60,4,100);
  waterfallRight.chamferEdges(40, waterHeight);
  waterfallRight.displayMesh();
}

/* -----------------------------------------------------------------------------
Cameras
----------------------------------------------------------------------------- */
void isometricView(float angle) {
  translate(width/2, height/2); 
  rotateX(PI/2 - asin(tan(PI/6)));
  rotateZ(PI/4 + angle);
}

/* -----------------------------------------------------------------------------
Save and change mode
----------------------------------------------------------------------------- */
void mouseClicked(){ 
  saveFrame("image.png");
}

void keyPressed(){
  //save 30 frames
  if (key == 'p') {
    save = true;
    //anim = true;
  }
  
  //change resolution
  else if(key == 'm') {
    if(highRes) {
      landscape3D.lowResolution();
      water.lowResolution();
      highRes = false;
    } else {
      landscape3D.highResolution();
      water.highResolution();
      highRes = true;
    }
  }
  
  //rotate view for terrain
  else if (key == CODED) {
    switch(keyCode) {
      case LEFT:
        angle += PI/2;
        break;
      case RIGHT:
        angle -= PI/2;
        break;
    }
  }
  
}