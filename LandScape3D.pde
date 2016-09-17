class Landscape3D {
  Block grid[][];
  float previousPosition[][];
  int xSize;
  int ySize;
  float size;
  color col;
  
  int centreIndexX;
  int centreIndexY;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */
  Landscape3D(int xSize_, int ySize_, float size_, color col_) {
    xSize = xSize_;
    ySize = ySize_;
    size = size_;
    
    col = col_;
    
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
  void display() {
    pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4);
    for(int i = 0; i < xSize; i++) {
      for(int j = 0; j < ySize; j++) {
        grid[i][j].display3D();
      }
    }
    popMatrix();
  }
  
  void displayMesh() {
    pushMatrix();
    translate(width/2, height/2);
    //isometric view
    rotateX(PI/2 - asin(tan(PI/6)));
    rotateZ(PI/4);
    noStroke();
    fill(col);
    for(int i = 0; i < xSize-1; i++) {
      beginShape(TRIANGLE_STRIP);
      //top surface
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
    popMatrix();
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
  
}