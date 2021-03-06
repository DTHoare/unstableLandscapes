/* -----------------------------------------------------------------------------
Block class allows for landscapes to be drawing using cubes, minecraft style.
Fairly basic and mostly unexplored. May be more interesting if shadows implemented
Currently used to store xys position data for meshes
----------------------------------------------------------------------------- */

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
    if(size_ >= 1) {
      size = size_;
    } else {
      size=1;
    }
    
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
  void display2D() {
    rectMode(TOP);
    noStroke();
    fill(col);
    
    pushMatrix();
    translate(position.x, position.y);
    rect(0,0,size,height);
    popMatrix();
  }
  
  void display3D() {
    noStroke();
    //stroke(0);
    fill(col);
    
    translate(position.x, position.y, position.z-200);
    fill(col);
    box(size, size, 400);
    
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