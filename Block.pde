class Block {
  PVector position;
  PVector velocity; 
  color col;
  float size;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */ 
  Block(PVector position_, float size_, color col_){
    position = position_.copy();
    size = size_;
    
    col = col_;
    
    velocity = new PVector(0,0);
  }
  
  /* -----------------------------------------------------------------------------
  Update
  ----------------------------------------------------------------------------- */ 
  void update(){
    position.add(velocity);
    velocity.mult(0);
  }
  
  /* -----------------------------------------------------------------------------
  Display
  ----------------------------------------------------------------------------- */ 
  void display() {
    rectMode(TOP);
    noStroke();
    fill(col);
    
    pushMatrix();
    translate(position.x, position.y);
    rect(0,0,size,height);
    popMatrix();
  }
  
  /* -----------------------------------------------------------------------------
  Add Velocity
  ----------------------------------------------------------------------------- */ 
  void addVelocity(PVector v){
    velocity.add(v);
  }
  
  
  /* -----------------------------------------------------------------------------
  setZero
  ----------------------------------------------------------------------------- */ 
  void setZero(){
    velocity.mult(0);
    position.y = 0;
  }
}