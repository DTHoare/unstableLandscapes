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
    maxLife = (int)random(25,75);
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