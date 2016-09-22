class Particle {
  PVector position;
  PVector velocity;
  int life;
  int maxLife;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */ 
  Particle(PVector pos, PVector v) {
    position = pos.copy();
    velocity = v.copy();
    maxLife = 10;
    life = maxLife;
  }
  
  /* -----------------------------------------------------------------------------
  Update
  ----------------------------------------------------------------------------- */ 
  void update() {
    life-=1;
    position.add(velocity);
    velocity.mult(0.98);
  }
  
  /* -----------------------------------------------------------------------------
  Display
  ----------------------------------------------------------------------------- */ 
  void display() {
    noStroke();
    fill(255-life*(255/maxLife));
    float size = (maxLife-float(life))/10;
    rect(position.x, position.y, size,size);
  }
  
  void display3D() {
    noStroke();
    fill(255-life*(255/maxLife));
    specular(255,255,255);
    float size = 1;
    pushMatrix();
      translate(position.x,position.y,position.z);
      box(size);
    popMatrix();
  }
  
  /* -----------------------------------------------------------------------------
  isDead
  ----------------------------------------------------------------------------- */ 
  boolean isDead() {
    if(life <=0) {
      return(true); 
    } else {
      return(false);
    }
  }
}