class Landscape3D {
  Block grid[][];
  float previousPosition[][];
  int xSize;
  int ySize;
  float size;
  color col;
  float specular;
  
  int centreIndexX;
  int centreIndexY;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */
  Landscape3D(int xSize_, int ySize_, float size_, color col_, float specular_) {
    xSize = xSize_;
    ySize = ySize_;
    size = size_;
    
    col = col_;
    specular=specular_;
    
    centreIndexX = floor(xSize/2);
    centreIndexY = floor(ySize/2);
    
    grid = new Block[xSize][ySize];
    previousPosition = new float[xSize][ySize];
  }
  
  /* -----------------------------------------------------------------------------
  createPlane
  ----------------------------------------------------------------------------- */
  void createPlane(float height_) {
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        PVector position = new PVector(float(i-centreIndexX)*size,float(j-centreIndexY)*size,height_);
        Block block = new Block(position, size, col);
        grid[i][j] = block;
        previousPosition[i][j] = grid[i][j].position.z;
      }
    }
  }
  
  void getPreviousPosition() {
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        previousPosition[i][j] = grid[i][j].position.z;
      }
    }
  }
  
  void setPreviousPosition() {
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        grid[i][j].position.z = previousPosition[i][j];
      }
    }
  }
  
  /* -----------------------------------------------------------------------------
  centrePlane
  ----------------------------------------------------------------------------- */
  void centrePlane() {
    float average = 0;
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        average+=  grid[i][j].position.z;
      }
    }
    average /= (xSize*ySize);
    
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        grid[i][j].position.z -= average;
      }
    }
  }
  
  /* -----------------------------------------------------------------------------
  Display
  ----------------------------------------------------------------------------- */ 
  //display using cuboids - lower quality
  void display() {
    specular(specular,specular,specular);
    pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4 + angle);
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        grid[i][j].display3D();
      }
    }
    popMatrix();
  }
  
  //display using a trianglestrip mesh
  void displayMesh() {
    specular(specular,specular,specular);
    pushMatrix();
    //center
    translate(width/2, height/2);
    
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4 + angle);
    noStroke();
    fill(col);
    
    //create the surface
    for(int i = 0; i < xSize-1; i++) {
      beginShape(TRIANGLE_STRIP);
      //top surface, in strips parralel to y axis
      for(int j = 0; j < ySize; j++) {
        vertex(grid[i][j].position.x, grid[i][j].position.y, grid[i][j].position.z);
        vertex(grid[i+1][j].position.x, grid[i+1][j].position.y, grid[i+1][j].position.z);
      }
      //wrap around to create walls
      vertex(grid[i][ySize-1].position.x, grid[i][ySize-1].position.y, -300);
      vertex(grid[i+1][ySize-1].position.x, grid[i+1][ySize-1].position.y, -300);
      
      vertex(grid[i][0].position.x, grid[i][0].position.y, -300);
      vertex(grid[i+1][0].position.x, grid[i+1][0].position.y, -300);
      
      vertex(grid[i][0].position.x, grid[i][0].position.y, grid[i][0].position.z);
      vertex(grid[i+1][0].position.x, grid[i+1][0].position.y, grid[i+1][0].position.z);
      
      endShape();
    }
    
    //create a wall on the two remaining sides
    beginShape(TRIANGLE_STRIP);
    int i = xSize-1;
    for(int j = 0; j < ySize; j++) {
      vertex(grid[i][j].position.x, grid[i][j].position.y, grid[i][j].position.z);
      vertex(grid[i][j].position.x, grid[i][j].position.y, -300);
    }
    endShape();
    
    beginShape(TRIANGLE_STRIP);
    for(int j = 0; j < ySize; j++) {
      vertex(grid[0][j].position.x, grid[0][j].position.y, grid[0][j].position.z);
      vertex(grid[0][j].position.x, grid[0][j].position.y, -300);
    }
    endShape();
    
    popMatrix();
  }
  
  void displayMeshLayered(int layers) {
    color originalColour = col;
    
    //start from bottom and work up to make transparency work
    for(int i = layers; i > 0; i--) {
      col = changeAlpha(waterBlue, (i+1)*(255/float(layers+1)));
      pushMatrix();
      translate(0,0,-i);
      displayMesh();
      popMatrix();
    }
    
    col = originalColour;
  }
  
  /* -----------------------------------------------------------------------------
  changeAlpha
  ----------------------------------------------------------------------------- */
  color changeAlpha(color col, float a){
    float r,g,b;
    r = red(col);
    g = green(col);
    b = blue(col);
    return(color(r,g,b,a));
  }
  
  /* -----------------------------------------------------------------------------
  Mid-Point Displacement
  ----------------------------------------------------------------------------- */ 
  void midPointDisplacement(float displacement_, float roughness_) {
    //parameters
    float displacement = displacement_;
    float roughness = roughness_;
    
    //setup corners
    grid[0][0].position.z = random(-displacement,displacement);
    grid[0][ySize-1].position.z = random(-displacement,displacement);
    grid[xSize-1][0].position.z = random(-displacement,displacement);
    grid[xSize-1][ySize-1].position.z = random(-displacement,displacement);
    
    //keep halving size of step
    for(int s = floor(xSize/2); s >= 1; s /= 2) {
      displacement *= roughness;
      
      //calculate based on diamond points
      for(int x = s; x < xSize; x+=(s*2)) {
        for(int y = s; y < ySize; y+=(s*2)) {
          diamondStep(x,y,s, random(-displacement,displacement));
        }
      }
      //calculate square point
      for(int x = s; x < xSize; x+=(s*2)) {
        for(int y = s; y < ySize; y+=(s*2)) {
          int[] xPoints = {x, x - s, x+s, x};
          int[] yPoints = {y - s, y, y, y+s};
          for(int i = 0; i <4; i++) {
            if(pointExists(xPoints[i], yPoints[i])) {
              squareStep(xPoints[i], yPoints[i], s, random(-displacement,displacement));
            }
            
          }
        }
      }
           
    }
  }
  
  void squareStep(int x, int y, int size, float offset) {
    //name points left to right, top to bottom
    int[] xPoints = {x, x - size, x+size, x};
    int[] yPoints = {y - size, y, y, y+size};
    grid[x][y].position.z = averagePoints(xPoints,yPoints) + offset;
  }
  
  void diamondStep(int x, int y, int size, float offset) {
    //name points left to right, top to bottom
    int[] xPoints = {x-size, x + size, x-size, x+size};
    int[] yPoints = {y - size, y-size, y+size, y+size};
    grid[x][y].position.z = averagePoints(xPoints,yPoints) + offset;
  }
  
  //calculates an average of a set of points
  //ignores points that don't exist
  float averagePoints(int[] x, int[] y) {
    float average = 0;
    float validPoints = 0;
    
    for(int i = 0; i < x.length; i++) {
      if(pointExists(x[i], y[i])) {
        validPoints += 1;
        average += getPoint(x[i], y[i]);
      }
    }
    
    return(average/validPoints);
  }
  
  boolean pointExists(int x, int y) {
    if(x < 0 || y < 0 || x >= xSize || y >= ySize) {
      return(false);
    } else {
      return(true);
    }
  }
  
  float getPoint(int x, int y) {
    return grid[x][y].position.z;
  }
  
  /* -----------------------------------------------------------------------------
  wave animations
  ----------------------------------------------------------------------------- */
  void perlinRipples() {
    for(int x = 0; x < xSize; x++) {
      for(int y = 0; y < ySize; y++) {
        grid[x][y].position.z = previousPosition[x][y] + map(noise(6*x/float(xSize),6*y/float(ySize)),0,1,-15,15)*sin(frameCount * 2*PI/30);
      }
    }
  }
  
  void xWaves(float a) {
    for(int x = 0; x < xSize; x++) {
      for(int y = 0; y < ySize; y++) {
        grid[x][y].position.z = previousPosition[x][y] + a*sin(x*2*PI/40 + frameCount * 2*PI/30);
      }
    }
  }
  
  void yWaves(float a, float scale, float lambda, float revs, float offset) {
    float A;
    for(int x = 0; x < xSize; x++) {
      for(int y = 0; y < ySize; y++) {
        A = map(noise(scale*x/float(xSize)+offset,scale*y/float(ySize)+offset),0,1,-a,a);
        grid[x][y].position.z += A*sin(y*2*PI/lambda + revs*frameCount * 2*PI/30);
      }
    }
  }
  
}