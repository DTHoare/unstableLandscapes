import java.util.*;
Landscape3D landscape3D;
Landscape3D water;
Landscape3D waterfallLeft;
Landscape3D waterfallRight;

boolean useBlocks = false;
float angle = 0;

ArrayList<Particle> particles;
int fps = 30;
boolean save = false;
int frames = 0;

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
  ortho();
  frameRate(fps); 
  //use a power of 2 + 1 for midpoint
  
  int landscapeN = (int)pow(2,8) + 1;
  float landscapeSize = 257;
  landscape3D = new Landscape3D(landscapeN,(landscapeSize-10)/float(landscapeN), redSand, 0);
  landscape3D.createPlane(0);
  landscape3D.midPointDisplacement(200,0.5);
  landscape3D.centrePlane();
  landscape3D.box = true;
  
  water = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  water.createPlane(0);
  //water.midPointDisplacement(5,0.65);
  water.getPreviousPosition();
  water.box = false;
  
  waterfallLeft = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallLeft.createPlane(0);
  waterfallLeft.getPreviousPosition();
  waterfallLeft.box = false;
  
  waterfallRight = new Landscape3D(landscapeN,landscapeSize/float(landscapeN), waterBlue, 220);
  waterfallRight.createPlane(0);
  waterfallRight.getPreviousPosition();
  waterfallRight.box = false;
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  //background(120,0,30);
  background(0);
  pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4);
    
    //main light
    lightSpecular(150,150,150);
    spotLight(200,200,200,0,500,100,
            0,-5,-1, PI/2, 50);
    //directionalLight(200,200,200,0,-5,-1);
    //bottom light
    //directionalLight(130,130,130,-2,1,1);
    
  popMatrix();
  
  pushMatrix();
    //center
    translate(width/2, height/2); 
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4 + angle);
    
    //display terrain
    if(useBlocks) {
      landscape3D.display();
    } else {
      landscape3D.displayMesh();
    }
  popMatrix();
  
  
  
  //sunset on the water!
  pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4);    
    sunset(0,-4);
  
    //make water with waves
    water.setPreviousPosition();
    water.radialWaves(3, 11, 40, 3, 0);
    water.radialWaves(5, 7,  70, 1, 100);
    water.chamferEdges(40, 4);
    water.displayMeshLayered(1);
    
    //noLights();
  
    //draw left waterfall
    translate(0, floor(waterfallLeft.size/2),0);
    rotateX(-PI/2);
    translate(0, floor(waterfallLeft.size/2),0);
    
    //lightSpecular(0,0,0);
    //directionalLight(100,100,100,-0.2,3,-0.8);
    //sunset(0,4);
    
    waterfallLeft.setPreviousPosition();
    waterfallLeft.waterfallRipple(4,80,3,0);
    waterfallLeft.waterfallRipple(3,60,4,100);
    waterfallLeft.chamferEdges(40, 4);
    waterfallLeft.displayMesh();
    
    //draw right waterfall
    translate(floor(waterfallLeft.size/2),0,0);
    translate(0, 0, -floor(waterfallLeft.size/2));
    rotateY(PI/2);
    
    waterfallRight.setPreviousPosition();
    waterfallRight.waterfallRipple(4,80,3,0);
    waterfallRight.waterfallRipple(3,60,4,100);
    waterfallRight.chamferEdges(40, 4);
    waterfallRight.displayMesh();
  popMatrix();

  
  if(save && frames <30) {
    saveFrame(frames + ".png");
    frames++;
  }
  
}

/* -----------------------------------------------------------------------------
lighting
----------------------------------------------------------------------------- */
void sunset(float x, float y){
  float xp, yp;
  xp = -x * 100;
  yp = -y * 100;
  //red glow
  lightSpecular(180,0,0);
  spotLight(180,0,0,xp*1.2,yp*1.2,50,
            x,y,-0.8, PI/3, 30);
  //orange glow
  lightSpecular(255,255,0);
  spotLight(255,255,0,xp*1.1,yp*1.1,50,
            x,y,-0.7, PI/6, 200);
  //white glow 
  lightSpecular(255,255,255);
  spotLight(255,255,255,xp,yp,20,
            x,y,-0.4, PI/12, 1000);
}

/* -----------------------------------------------------------------------------
Save
----------------------------------------------------------------------------- */
void mouseClicked(){ 
  saveFrame("image.png");
}

void keyPressed(){
  //switch rendering mode
  if(key == 'm') {
    if(useBlocks) {
      useBlocks = false;
    } else {
      useBlocks = true;
    }
  } 
  //save 30 frames
  else if (key == 's') {
    save = true;
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

/* -----------------------------------------------------------------------------
iterateParticles
----------------------------------------------------------------------------- */
void iterateParticles() {
  pushMatrix();
  //center grid
  translate(width/2, 2*height/3);
  
  //Iterator 
  Iterator<Particle> it = particles.iterator();
  while (it.hasNext()) {
    Particle p = it.next();
    p.update();
    if (p.isDead()) {
      it.remove();
    } else {
      p.display();
    }
  }
  popMatrix();
}