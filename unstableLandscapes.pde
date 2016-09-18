import java.util.*;
Landscape3D landscape3D;
Landscape3D water;

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
  
  int landscapeN = (int)pow(2,9) + 1;
  float landscapeSize = 400;
  landscape3D = new Landscape3D(landscapeN,landscapeN,landscapeSize/landscapeN, redSand, 0);
  landscape3D.createPlane(0);
  landscape3D.midPointDisplacement(200,0.5);
  landscape3D.centrePlane();
  
  water = new Landscape3D(landscapeN,landscapeN,landscapeSize/landscapeN, waterBlue, 220);
  water.createPlane(0);
  //water.midPointDisplacement(5,0.65);
  water.getPreviousPosition();
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  background(120,0,30);
  pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4 + PI/2);
    
    directionalLight(180,180,180,5,0,-1);
    
  popMatrix();
  
  
  if(useBlocks) {
    landscape3D.display();
  } else {
    landscape3D.displayMesh();
  }
  
  //sunset on the water!
  pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4 + PI/2);
    
    sunset(4,0);
    
  popMatrix();
  
  water.setPreviousPosition();
  water.yWaves(3, 11, 40, 3, 0);
  water.yWaves(5, 7,  70, 1, 100);
  water.displayMeshLayered(30);
  
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
  lightSpecular(180,0,0);
  spotLight(180,0,0,xp*1.2,yp*1.2,50,
            x,y,-0.8, PI/2, 30);
  lightSpecular(255,255,0);
  spotLight(255,255,0,xp*1.1,yp*1.1,50,
            x,y,-0.7, PI/3, 200);
  lightSpecular(255,255,255);
  spotLight(255,255,255,xp,yp,20,
            x,y,-0.4, PI/3, 1000);
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