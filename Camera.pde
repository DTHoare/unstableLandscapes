/* -----------------------------------------------------------------------------
Camera class allows for first person camera control. Position is controlled using
wasd keys, and the direction controlled by holding mouse down. 

firstPersonView() follows wave height for a given position like a boat
firstPersonViewFlying() allows using shift and control to alter height
----------------------------------------------------------------------------- */

class Camera{
  PVector position;
  PVector direction;
  
  Camera(PVector p, PVector d) {
    position = p.copy();
    //normalise direction to 1
    direction = d.copy().div(d.mag());
  }
  
  void firstPersonView() {    
    beginCamera();
      //adjust inputs to index for getPoint
      //set the user to rock with the sea
      //directions are multiplied by 1000 to approximate infinity,
      //camera wants a point to look at rather than a direction
      camera(-position.x, -position.y, -getWaterHeight(),
        direction.x*1000, direction.y*1000, direction.z*1000,
        0, 0, 1);
        
      //'undo' isometric
      rotateZ(-PI/4);
      rotateX(-PI/2 + asin(tan(PI/6)));    
      translate(-width/2, -height/2);
    endCamera(); 
  }
  
  void firstPersonViewFlying() {    
    beginCamera();
      //adjust inputs to index for getPoint
      //set the user to rock with the sea
      camera(-position.x, -position.y, -position.z,
        direction.x*1000, direction.y*1000, direction.z*1000,
        0, 0, 1);
        
      //'undo' isometric
      rotateZ(-PI/4);
      rotateX(-PI/2 + asin(tan(PI/6)));    
      translate(-width/2, -height/2);
    endCamera(); 
  }
  
  float getWaterHeight(){
    int xi = int((position.x/water.blockSize)+floor(water.n/2));
    int yi = int((position.y/water.blockSize)+floor(water.n/2));
    return(water.getPoint(xi, yi));
  }
  
  void moveWithMouse(){
    if(mousePressed) {
      //move depending on position from centre of the screen
      float horizontal = -0.5*(mouseX-width/2)/width;
      float vertical = 0.5*(mouseY-height/2)/height;
      
      //get angle of current viewing direction and add angle corresponding to mouse position
      float angleH = atan2(direction.y, direction.x) + horizontal;
      float angleV = atan2(direction.z, sqrt(pow(direction.x,2) + pow(direction.y,2))) + vertical;
      
      //set new position based on combined angles
      direction.x += cos(angleH);
      direction.y += sin(angleH);
      direction.z += sin(angleV);
      
      direction.div(direction.mag());
    }
  }
  
  void move() {
    if (keyPressed) {
      if(key == 'w') {
        position.x -= direction.x;
        position.y -= direction.y;
      } else if (key == 's') {
        position.x += direction.x;
        position.y += direction.y;
      } else if(key == 'd') {
        position.x -= direction.y;
        position.y += direction.x;
      } else if(key == 'a') {
        position.x += direction.y;
        position.y -= direction.x;
      } else if(key == CODED) {
        switch(keyCode) {
          case SHIFT:
            position.z += 1;
            break;
          case CONTROL:
            position.z -= 1;
            break;
        }
      }
      
    }
    
  }
  
}