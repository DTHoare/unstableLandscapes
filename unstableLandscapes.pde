import java.util.*;
Landscape2D landscape;
Landscape2D mountains;
Landscape2D distantMountains;
Landscape2D distantMountains2;
ArrayList<Particle> particles;
int fps = 30;
color skyBlue = color(135,206,250);
color waterBlue = color(70,90,220);
color grass = color(10,149,84);
color grassFar = color(30,169,134);
color grassFar2 = color(50,199,164);
color sand = color(239,221,111);

/* -----------------------------------------------------------------------------
Setup
----------------------------------------------------------------------------- */ 
void setup() {
  size(500,500);
  frameRate(fps);
  //use a power of 2 + 1 for midpoint
  landscape = new Landscape2D((int)pow(2,12) + 1,0.2, sand);
  landscape.createPlane(2*height/3);
  landscape.midPointDisplacement(height/7,0.5);
  particles = new ArrayList();
  
  mountains = new Landscape2D((int)pow(2,12) + 1,0.2, grass);
  mountains.createPlane(0.6*height);
  mountains.midPointDisplacement(150,0.55);
  
  distantMountains = new Landscape2D((int)pow(2,12) + 1,0.2, grassFar);
  distantMountains.createPlane(0.5*height);
  distantMountains.midPointDisplacement(150,0.55);
  distantMountains2 = new Landscape2D((int)pow(2,12) + 1,0.2, grassFar2);
  distantMountains2.createPlane(0.4*height);
  distantMountains2.midPointDisplacement(150,0.55);
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  //draw background
  background(skyBlue);
  distantMountains2.display();
  distantMountains.display();
  mountains.display();
  noStroke();
  fill(waterBlue);
  rectMode(CORNER);
  rect(0,height/2,width,height);
  
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
  
    //perform landscape operations
  //landscape.moveAllNoise();
  //landscape.bounceToPeaksSigmoid();
  landscape.display();
  
}

/* -----------------------------------------------------------------------------
Save
----------------------------------------------------------------------------- */
void mouseClicked(){ 
  saveFrame("image.png");
}