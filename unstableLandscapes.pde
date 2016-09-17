import java.util.*;
Landscape3D landscape3D;
Landscape3D water;
ArrayList<Particle> particles;
int fps = 30;
color skyBlue = color(135,206,250);
color waterBlue = color(70,90,220, 20);
color grass = color(10,149,84);
color grassFar = color(30,169,134);
color grassFar2 = color(50,199,164);
color sand = color(239,221,111);
boolean useBlocks = false;

/* -----------------------------------------------------------------------------
Setup
----------------------------------------------------------------------------- */ 
void setup() {
  size(540,540, P3D);
  ortho();
  frameRate(fps);
  //use a power of 2 + 1 for midpoint
  
  landscape3D = new Landscape3D((int)pow(2,10) + 1,(int)pow(2,10) + 1,0.4, sand);
  landscape3D.createPlane(0);
  landscape3D.midPointDisplacement(200,0.5);
  landscape3D.centrePlane();
  
  water = new Landscape3D((int)pow(2,10) + 1,(int)pow(2,10) + 1,0.4, waterBlue);
  water.createPlane(0);
  water.midPointDisplacement(10,0.7);
}

/* -----------------------------------------------------------------------------
Draw
----------------------------------------------------------------------------- */ 
void draw() {
  background(skyBlue);
  directionalLight(255,255,255,1,2,-1);
  
  if(useBlocks) {
    landscape3D.display();
  } else {
    landscape3D.displayMesh();
  }
  
  water.display();
  
}

/* -----------------------------------------------------------------------------
Save
----------------------------------------------------------------------------- */
void mouseClicked(){ 
  saveFrame("image.png");
}

void keyPressed(){
  if(useBlocks) {
    useBlocks = false;
  } else {
    useBlocks = true;
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