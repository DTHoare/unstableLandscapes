class Landscape2D {
  Block[] grid;
  float[] previousPosition;
  float[] nextPosition;
  float size;
  int n;
  int centreIndex;
  color col;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */ 
  Landscape2D(int n_, float size_, color col_) {
    n = n_;
    size = size_;
    grid = new Block[n];
    centreIndex = floor(n/2);
    col = col_;
    
    previousPosition = new float[n];
    nextPosition = new float[n];
  }
  
  /* -----------------------------------------------------------------------------
  createPlane
  ----------------------------------------------------------------------------- */ 
  void createPlane(float height_) {
    for(int i = 0; i < n; i++) {
      PVector position = new PVector(float(i-centreIndex)*size,height_);
      Block block = new Block(position, 1, col);
      grid[i] = block;
      previousPosition[i] = grid[i].position.y;
    }
  }
  
  /* -----------------------------------------------------------------------------
  Display
  ----------------------------------------------------------------------------- */ 
  void display() {
    pushMatrix();
    translate(width/2, 0);
    for(int i = 0; i < n; i++) {
      grid[i].display();
    }
    popMatrix();
  }
  
  /* -----------------------------------------------------------------------------
  Mid-Point Displacement
  ----------------------------------------------------------------------------- */ 
  void midPointDisplacement(float displacement_, float roughness_) {
    //parameters
    float displacement = displacement_;
    float roughness = roughness_;
    
    //adjust end points
    grid[0].position.y += random(-displacement,displacement);
    grid[n-1].position.y += random(-displacement,displacement);
    displacement *= roughness;
    
    for(int segments = 1; segments < n; segments *= 2) {
      for( int centrePoint = (n/segments)/2; centrePoint < n; centrePoint += n/segments) {
        grid[centrePoint].position.y = grid[centrePoint - (n/segments)/2].position.y;
        grid[centrePoint].position.y += grid[centrePoint + (n/segments)/2].position.y;
        grid[centrePoint].position.y /=2;
        grid[centrePoint].position.y += random(-displacement,displacement);
      }
      //adjust displacement
      displacement *= roughness;
    }
  }
  
  /* -----------------------------------------------------------------------------
  moveAllNoise
  ----------------------------------------------------------------------------- */ 
  void moveAllNoise() {
    //make a puff come off
    if(frameCount%30 == 15) {
      for(int i = 0; i < n; i++) {
        PVector pos = grid[i].position.copy();
        PVector v = new PVector(random(-0.1,0.1),0);
        v.y = (pos.y)/10;
        Particle particle = new Particle(pos,v);
        particles.add(particle);
      }
    }
    int offset = 10000*( floor(frameCount/60) % 2 );

    for(int i = 0; i < n; i++) {
      PVector v = new PVector(0, noise(float(i)/700 + offset) -0.5);
      v.mult(cos(frameCount * 2*PI/60));
      v.mult(20);
      grid[i].addVelocity(v);
      grid[i].update();
    }    
  }
  
  /* -----------------------------------------------------------------------------
  bounceToPeaksSigmoid
  ----------------------------------------------------------------------------- */ 
  void bounceToPeaksSigmoid() {
    int period = int(2*fps);
    
    //get previous position
    float peakHeight;
    if(frameCount % period == 0) {
      for(int i = 0; i < n; i++) {
        previousPosition[i] = grid[i].position.y;
        peakHeight = 400*(noise(float(i)/700 + frameCount) -0.5);
        nextPosition[i] = peakHeight - previousPosition[i];
      }  
    }
    
    //move blocks
    for(int i = 0; i < n; i++) {
      //subtrct 0.5 to get centered on 0
      grid[i].position.y = previousPosition[i] + Math.periodicSigmoid(frameCount, nextPosition[i], 2, period);
      grid[i].position.y += Math.dampedOscillation(frameCount, nextPosition[i]/5, period);
    }  
  }
  
}