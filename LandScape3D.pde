/* -----------------------------------------------------------------------------
Landscape3D contains many functions for calculating and drawing terrains and water.
It includes a diamond-square algorithm for terrain generation, and many sinusoidal
wave equations with some level of perlin noise includes.

Contains functions to display as either meshes or blocks. Meshes are more realistic.
----------------------------------------------------------------------------- */

class Landscape3D {
  Block grid[][];
  //previous/initial position stores to allow for easy looping calculations
  float previousPosition[][];
  int n;
  //blockSize is spacing between points, size is total size, blockSize = size/n
  float blockSize;
  float size;
  
  //drawing parameters
  color col;
  float specular;
  float shiny;
  //draw resolution gives stepsize of iterating though array. Ie 1 = highest resolution
  int drawResolution;
  
  int centreIndexX;
  int centreIndexY;
  
  //box allows drawing outside walls to give appearence of solid
  boolean box;
  float[] yBoundary;
  
  ArrayList<Particle> particles;
  
  /* -----------------------------------------------------------------------------
  Constructor
  ----------------------------------------------------------------------------- */
  Landscape3D(int n_, float blockSize_, color col_, float specular_) {
    n = n_;
    blockSize = blockSize_;
    size = float(n) * blockSize;
    
    col = col_;
    specular=specular_;
    shiny = 0;
    
    centreIndexX = floor(n/2);
    centreIndexY = floor(n/2);
    
    grid = new Block[n][n];
    previousPosition = new float[n][n];
    
    box = true;
    
    yBoundary = new float[n];
    //default yboundary v large
    for(int i = 0; i < n; i ++){
      yBoundary[i] = -1000;
    }
    
    particles = new ArrayList<Particle>();
    drawResolution = 32;
  }
  
  /* -----------------------------------------------------------------------------
  createPlane
  ----------------------------------------------------------------------------- */
  void createPlane(float height_) {
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        //create new block which holds xyz position data
        PVector position = new PVector(float(i-centreIndexX)*blockSize,float(j-centreIndexY)*blockSize,height_);
        Block block = new Block(position, blockSize, col);
        grid[i][j] = block;
        previousPosition[i][j] = grid[i][j].position.z;
      }
    }
  }
  
  void getPreviousPosition() {
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        previousPosition[i][j] = grid[i][j].position.z;
      }
    }
  }
  
  void setPreviousPosition() {
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        grid[i][j].position.z = previousPosition[i][j];
      }
    }
  }
  
  /* -----------------------------------------------------------------------------
  centrePlane
  ----------------------------------------------------------------------------- */
  //set the average z value of the terrain to 0
  //used for terrains to allow easy water placement
  void centrePlane() {
    float average = 0;
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        average+=  grid[i][j].position.z;
      }
    }
    average /= (float(n*n));
    
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        grid[i][j].position.z -= average;
      }
    }
  }
  
  /* -----------------------------------------------------------------------------
  calculateEdge
  ----------------------------------------------------------------------------- */
  //returns an array of z positions of the given edge 
  //edge 1: y = 0
  //edge 2: x = width
  //edge 3: y = height
  //edge 4: x = 0
  float[] calculateEdge(int i) {
    int x, y;
    float[] edge = new float[n];
    switch(i){
      case 1:
        y = 0;
        for(x = 0; x < n; x++){
          edge[x] = grid[x][y].position.z;
        }
        break;
        
      case 2:
        x = n-1;
        for(y = 0; y < n; y++){
          edge[y] = grid[x][y].position.z;
        }
        break;
        
      case 3:
        y = n-1;
        for(x = 0; x < n; x++){
          edge[x] = grid[x][y].position.z;
        }
        break;
      
      default:
        x = 0;
        for(y = 0; y < n; y++){
          edge[y] = grid[x][y].position.z;
        }
        break;
    }
    
    return edge;
  }
  
  /* -----------------------------------------------------------------------------
  Display
  ----------------------------------------------------------------------------- */ 
  //display using cubes - lower quality
  void display() {
    specular(specular,specular,specular);
    for(int i = 0; i < n; i++) {
      for(int j = 0; j < n; j++) {
        grid[i][j].display3D();
      }
    }
  }
  
  //display using a trianglestrip mesh
  void displayMesh() {
    specular(specular,specular,specular);
    shininess(shiny);
    noStroke();
    fill(col);
    
    //create the surface
    for(int i = 0; i < n-1; i+=drawResolution) {
      beginShape(TRIANGLE_STRIP);
      
      //top surface, in strips parralel to y axis
      for(int j = 0; j < n; j+=drawResolution) {
        fill(perlinColour(grid[i][j].position.x,grid[i][j].position.y,90));
        vertex(grid[i][j].position.x, grid[i][j].position.y, grid[i][j].position.z);
        vertex(grid[i+drawResolution][j].position.x,
          grid[i+drawResolution][j].position.y,
          grid[i+drawResolution][j].position.z);
      }
      
      if(box){
        //wrap around to create walls
        vertex(grid[i][n-drawResolution].position.x, grid[i][n-drawResolution].position.y, 200);
        vertex(grid[i+drawResolution][n-drawResolution].position.x,
          grid[i+drawResolution][n-drawResolution].position.y, 200);
        
        vertex(grid[i][0].position.x, grid[i][0].position.y, 200);
        vertex(grid[i+drawResolution][0].position.x, grid[i+drawResolution][0].position.y, 200);
        
        vertex(grid[i][0].position.x, grid[i][0].position.y, grid[i][0].position.z);
        vertex(grid[i+drawResolution][0].position.x,
          grid[i+drawResolution][0].position.y,
          grid[i+drawResolution][0].position.z);
      }
      endShape();
    }
    
    if(box) {
      //create a wall on the two remaining sides
      beginShape(TRIANGLE_STRIP);
      int i = n-1;
      for(int j = 0; j < n; j+=drawResolution) {
        vertex(grid[i][j].position.x, grid[i][j].position.y, grid[i][j].position.z);
        vertex(grid[i][j].position.x, grid[i][j].position.y, 200);
      }
      endShape();
      
      beginShape(TRIANGLE_STRIP);
      for(int j = 0; j < n; j+=drawResolution) {
        vertex(grid[0][j].position.x, grid[0][j].position.y, grid[0][j].position.z);
        vertex(grid[0][j].position.x, grid[0][j].position.y, 200);
      }
      endShape();
    }
    
    
  }
  
  //allows for multiple meshes to be used for transparency
  //processing seems to have a problem with correct order for transparency
  void displayMeshLayered(int layers) {
    color originalColour = col;
    
    //start from bottom and work up to make transparency work
    for(int i = layers; i > 0; i--) {
      col = changeAlpha(originalColour, (i+1)*(255/float(layers+1)));
      pushMatrix();
      translate(0,0,-(i-1));
      displayMesh();
      popMatrix();
    }
    
    col = originalColour;
  }
  
  void highResolution() {
    drawResolution = 1;
  }
  
  void lowResolution() {
    drawResolution = 32;
  }
  
  /* -----------------------------------------------------------------------------
  colour adjustments
  ----------------------------------------------------------------------------- */
  color changeAlpha(color col, float a){
    float r,g,b;
    r = red(col);
    g = green(col);
    b = blue(col);
    return(color(r,g,b,a));
  }
  
  //provide some perlin noise based variation to colour
  color perlinColour(float x, float y, float variation) {
    float r,g,b;
    r = red(col) + variation*noise(x*0.1,y*0.1,0);
    g = green(col) + variation*noise(x*0.1,y*0.1,753);
    b = blue(col) + variation*noise(x*0.1,y*0.1,364);
    r = constrain(r,0,255);
    g = constrain(g,0,255);
    b = constrain(b,0,255);
    return(color(r,g,b));
  }
  
  /* -----------------------------------------------------------------------------
  Mid-Point Displacement
  ----------------------------------------------------------------------------- */ 
  //standard diamond-square algorithm
  void midPointDisplacement(float displacement_, float roughness_) {
    //parameters
    float displacement = displacement_;
    float roughness = roughness_;
    
    //setup corners
    grid[0][0].position.z = random(-displacement,displacement);
    grid[0][n-1].position.z = random(-displacement,displacement);
    grid[n-1][0].position.z = random(-displacement,displacement);
    grid[n-1][n-1].position.z = random(-displacement,displacement);
    
    //keep halving blockSize of step
    for(int s = floor(n/2); s >= 1; s /= 2) {
      displacement *= roughness;
      
      //calculate based on diamond points
      for(int x = s; x < n; x+=(s*2)) {
        for(int y = s; y < n; y+=(s*2)) {
          diamondStep(x,y,s, random(-displacement,displacement));
        }
      }
      //calculate square point
      for(int x = s; x < n; x+=(s*2)) {
        for(int y = s; y < n; y+=(s*2)) {
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
  
  void squareStep(int x, int y, int blockSize, float offset) {
    //name points left to right, top to bottom
    int[] xPoints = {x, x - blockSize, x+blockSize, x};
    int[] yPoints = {y - blockSize, y, y, y+blockSize};
    grid[x][y].position.z = averagePoints(xPoints,yPoints) + offset;
  }
  
  void diamondStep(int x, int y, int blockSize, float offset) {
    //name points left to right, top to bottom
    int[] xPoints = {x-blockSize, x + blockSize, x-blockSize, x+blockSize};
    int[] yPoints = {y - blockSize, y-blockSize, y+blockSize, y+blockSize};
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
    if(x < 0 || y < 0 || x >= n || y >= n) {
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
    for(int x = 0; x < n; x++) {
      for(int y = 0; y < n; y++) {
        grid[x][y].position.z = previousPosition[x][y] + map(noise(6*x/float(n),6*y/float(n)),0,1,-15,15)*sin(frameCount * 2*PI/30);
      }
    }
  }
  
  void xWaves(float a) {
    for(int x = 0; x < n; x++) {
      for(int y = 0; y < n; y++) {
        grid[x][y].position.z = previousPosition[x][y] + a*sin(x*2*PI/40 + frameCount * 2*PI/30);
      }
    }
  }
  
  void yWaves(float a, float scale, float lambda, float revs, float offset) {
    float A, xp, yp;
    for(int x = 0; x < n; x+=drawResolution) {
      for(int y = 0; y < n; y+=drawResolution) {
        xp = float(x)*blockSize;
        yp = float(y)*blockSize;
        A = map(noise(scale*xp/float(n)+offset,scale*yp/float(n)+offset),0,1,-a,a);
        grid[x][y].position.z += A*sin(-yp*2*PI/lambda + revs*frameCount * 2*PI/30);
      }
    }
  }
  
  void radialWaves(float a, float scale, float lambda, float revs, float offset) {
    float A, xp, yp, xFromCentre, yFromCentre;
    for(int x = 0; x < n; x+=drawResolution) {
      for(int y = 0; y < n; y+=drawResolution) {
        xp = float(x)*blockSize;
        yp = float(y)*blockSize;
        A = map(noise(scale*xp/float(n)+offset,scale*yp/float(n)+offset),0,1,-a,a);
        
        xFromCentre = float(x-floor(n/2)) * blockSize;
        yFromCentre = float(y-floor(n/2)) * blockSize;
        grid[x][y].position.z += A*sin(-sqrt(pow(xFromCentre,2) + pow(yFromCentre,2))*2*PI/lambda + revs*frameCount * 2*PI/30);
      }
    }
  }
  
  void chamferEdges(int edgeSize, float chamferHeight) {
    int x, y;
    float distance;
    
    //this quadratic funtion is the result of solving differential equation
    //with boundary conditions on getting this to look nice
    float A, B, C, L;
    float h = chamferHeight;
    L = 2*(h-1);
    int chamferLength = int(L);
    
    A = -1;
    A /= 4*(h-2);
    
    B = h-1;
    B /= h-2;
    
    C = 1;
    C /= 2-h;
    
    for(x = 0; x < n; x+=drawResolution) {
      for(y = 0; y < n; y+=drawResolution) {
        //straight edge
        distance = distanceToEdge(float(x),float(y),float(chamferLength));
        if(distance < 2) {
          grid[x][y].position.z = distance;
        }
        //round edge
        else if(distance < chamferLength) {
          grid[x][y].position.z = A*distance*distance + B*distance + C;
        }
        //flatten
        else if(distance < edgeSize) {
          //grid[x][y].position.z *= pow((distance-L)/float(edgeSize-chamferLength),1);
          //grid[x][y].position.z += chamferHeight * (float(edgeSize)-distance)/float(edgeSize-chamferLength);
          
          grid[x][y].position.z *= Math.periodicSigmoid(distance - L, 1, 0.2, float(edgeSize-chamferLength));
          grid[x][y].position.z += Math.periodicSigmoid(float(edgeSize)-(distance+1), chamferHeight, 0.2, float(edgeSize-chamferLength));
        }
      }
    }
    

  }
  
  float distanceToEdge(float x, float y, float chamfer) {
    //check linear distances
    float xDistance, yDistance;
    xDistance = min(x, (n-1)-x)*blockSize;
    yDistance = min(y, (n-1)-y)*blockSize;
    //cases not in corners
    if(xDistance > chamfer || yDistance > chamfer) {
      return(min(xDistance,yDistance));
    }
    
    //corner cases
    else {
      float r = sqrt(pow(xDistance-chamfer,2) + pow(yDistance-chamfer,2));
      return(chamfer - r);
    }
    
  }
  
  void waterfallRipple(float a, float lambda, float revs, float offset) {
    float A, xp, yp;
    for(int x = 0; x < n; x++) {
      for(int y = 0; y < n; y++) {
        xp = float(x) * blockSize;
        yp = float(y) * blockSize;
        A = yp * a/float(n);
        A *= map(noise(12*xp/float(n)+offset,3*yp/float(n)+offset),0,1,-a,a);
        //waves falling down
        grid[x][y].position.z += A*pow(sin(-yp*2*PI/lambda + revs*frameCount * 2*PI/30),2);
        //standing waves across
        grid[x][y].position.z += A*pow(cos(revs*frameCount * 2*PI/30)*sin(xp*2*PI/lambda),2);
        grid[x][y].position.z += abs(A);
      }
    }
  }
  
  /* -----------------------------------------------------------------------------
  particle effects
  ----------------------------------------------------------------------------- */
  //generate particles to represent foam produced by the waterfall
  //needs work, doesn't look very good
  void waterfallFoam(float threshold) {
    PVector v;
    PVector pos;
    Particle p;
    for(int x = 0; x < n; x++) {
      for(int y = 0; y < n; y++) {
        if(grid[x][y].position.z > threshold) {
          v = new PVector(random(-1,1),(y)/n,5*(n-y)/n);
          pos = new PVector(grid[x][y].position.x,grid[x][y].position.y-10,grid[x][y].position.z-10);
          p = new Particle(pos,v);
          particles.add(p);
        }
      }
    }
  }
  
  //update delete existing particles
  void iterateParticles() {
    //Iterator 
    Iterator<Particle> it = particles.iterator();
    while (it.hasNext()) {
      Particle p = it.next();
      p.update();
      if (p.isDead()) {
        it.remove();
      } else {
        p.display3D();
      }
    }
  }
  
}