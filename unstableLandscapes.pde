import java.util.*;
Landscape3D landscape3D;
Landscape3D water;
Landscape3D waterfallLeft;
Landscape3D waterfallRight;

boolean useBlocks = false;
float angle = 0;
float waterHeight = 3;

int fps = 30;
boolean save = false;
int frames = 0;
boolean anim = false;

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
  //ortho();
  frameRate(fps); 
  //use a power of 2 + 1 for midpoint
  
  int landscapeN = (int)pow(2,10) + 1;
  float landscapeSize = 257;
  
  landscape3D = new Landscape3D(landscapeN,(landscapeSize-2*waterHeight)/float(landscapeN), redSand, 0);
  landscape3D.createPlane(0);
  landscape3D.midPointDisplacement(200,0.45);
  landscape3D.centrePlane();
  landscape3D.box = false;
  
  water = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  water.createPlane(waterHeight);
  water.getPreviousPosition();
  water.box = false;
  
  waterfallLeft = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallLeft.createPlane(waterHeight);
  waterfallLeft.getPreviousPosition();
  waterfallLeft.box = false;
  
  waterfallRight = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallRight.createPlane(waterHeight);
  waterfallRight.getPreviousPosition();
  waterfallRight.box = false;
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  //background(120,0,30);
  background(0);
  //background(120*(0.5 + 0.5*(cos(2*PI*frameCount/15))),0,190*(1-(0.5 + 0.5*(cos(2*PI*frameCount/15)))));
  //lighting
  pushMatrix();
    isometricView(0);
    //sunsetGeneral(0,-4, -1); 
    
    if(anim) {
      sunsetWaterAnim(0,-4, -1);
    } else {
      sunsetWater(0,-4, -1);
    }
  popMatrix();
  
  //land
  pushMatrix();
    isometricView(angle);
    drawTerrain();
  popMatrix();

  //Water
  pushMatrix();
    isometricView(0);   
    //sunsetWater(0,-4, -1);
  
    //make water with waves
    drawWater();
    //drawWaterfallLeft();
    //drawWaterfallRight();  
  popMatrix();

  
  if(save && frames <30) {
    saveFrame(frames + ".png");
    frames++;
  }
  
  float angle = 2*PI*(mouseX-width/2)/width;
  float angle2 = 2*PI*(mouseY-height/2)/height;
  beginCamera();
    camera(100, 100, -15, 1000*cos(-angle), 1000*sin(-angle), 800*sin(angle2), 0, 0, 1);
    rotateZ(-PI/4);
    rotateX(-PI/2 + asin(tan(PI/6)));    
    translate(-width/2, -height/2);
  endCamera();
  
}
/* -----------------------------------------------------------------------------
landScapes
----------------------------------------------------------------------------- */
void drawTerrain() {
  landscape3D.displayMesh();
}

void drawWater() {
  water.setPreviousPosition();
  water.radialWaves(3, 11, 15, 3, 0);
  water.radialWaves(5, 7,  40, 1, 100);
  water.chamferEdges(40, waterHeight);
  water.displayMeshLayered(1);
}

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
lighting
----------------------------------------------------------------------------- */
void sunsetGeneral(float x, float y, float z) {
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100 - 20;
  spotLight(200,200,150,xp,yp,zp,
            x,y,z, PI/2, 50);
  spotLight(200,200,150,xp,yp,zp,
          x,y,z, PI/2, 50);
  spotLight(150,150,230,xp,yp*1.2,zp*1.2,
          x,y,z, PI/2, 100);
}

void sunsetWater(float x, float y, float z){
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100 - 20;
  
  //red glow
  lightSpecular(180,0,0);
  spotLight(180,0,0,xp*1.2,yp*1.2,zp,
            x,y,z, PI/3, 30);
  //orange glow
  lightSpecular(255,255,0);
  spotLight(255,255,0,xp*1.1,yp*1.1,zp,
            x,y,z, PI/6, 200);
  //white glow 
  lightSpecular(255,255,205);
  spotLight(255,255,205,xp,yp,zp,
            x,y,z, PI/12, 1000);
  
}

void sunsetWaterAnim(float x, float y, float z){
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100 - 20;
  
  float sunsetMod = 0.5 + 0.5*(cos(2*PI*frameCount/15));
  float daylightMod = 1 - sunsetMod;
  
  rotateX(2*PI/30 * frameCount);
  //red glow
  lightSpecular(sunsetMod*180,0,0);
  spotLight(sunsetMod*180,0,0,xp*1.2,yp*1.2,zp,
            x,y,z, PI/3, 30);
  //orange glow
  lightSpecular(sunsetMod*255,sunsetMod*255,0);
  spotLight(sunsetMod*255,sunsetMod*255,0,xp*1.1,yp*1.1,zp,
            x,y,z, PI/6, 200);
  //white glow 
  lightSpecular(sunsetMod*255,sunsetMod*255,sunsetMod*205);
  spotLight(sunsetMod*255,sunsetMod*255,sunsetMod*205,xp,yp,zp,
            x,y,z, PI/12, 1000);
  
  //daylight
  lightSpecular(daylightMod*150,daylightMod*150,daylightMod*200);
  spotLight(daylightMod*255,daylightMod*255,daylightMod*255,xp,yp,zp*2,
            x,y,z*2, PI, 10);
}

/* -----------------------------------------------------------------------------
Save
----------------------------------------------------------------------------- */
void mouseClicked(){ 
  saveFrame("image.png");
}

void keyPressed(){
  //save 30 frames
  if (key == 's') {
    save = true;
    //anim = true;
  }
  //rotate view
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