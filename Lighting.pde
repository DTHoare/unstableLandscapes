/* -----------------------------------------------------------------------------
lighting
Contains functions related to lighting the scene in 3D. Material properties
controlled in Landscape3D.
Also contains some background/sun functions
----------------------------------------------------------------------------- */
void sunsetGeneral(float x, float y, float z) {
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100;
  spotLight(200,200,150,xp,yp,zp,
            x,y,z, PI, 50);
  spotLight(200,200,150,xp,yp,zp,
          x,y,z, PI, 50);
  spotLight(150,150,230,xp,yp*1.2,zp*1.2,
          x,y,z, PI, 100);
}

void sunsetWater(float x, float y, float z){
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100;
  
  directionalLight(30,30,50, x, y/8, z*2.8);
  //red glow
  lightSpecular(220,0,0);
  spotLight(220,0,0,xp*1.2,yp*1.2,zp*1.3,
            x,y,z*1.3, PI/4, 20);
  //orange glow
  lightSpecular(255,255,0);
  spotLight(255,255,0,xp*1.1,yp*1.1,zp*1.2,
            x,y,z*1.1, PI/7, 100);
  //white glow 
  lightSpecular(255,255,205);
  spotLight(255,255,205,xp,yp,zp*1.1,
            x,y,z, PI/18, 1000);
  
}

void sunsetWaterAnim(float x, float y, float z){
  float xp, yp, zp;
  xp = -x * 100;
  yp = -y * 100;
  zp = -z * 100 - 20;
  
  float sunsetMod = 0.5 + 0.5*(cos(2*PI*frameCount/15));
  float daylightMod = 1 - sunsetMod;
  
  rotateX(2*PI/30 * frameCount);
  //red glow
  lightSpecular(sunsetMod*180,0,0);
  spotLight(sunsetMod*180,0,0,xp*1.2,yp*1.2,zp,
            x,y,z, PI/3, 30);
  //orange glow
  lightSpecular(sunsetMod*255,sunsetMod*255,0);
  spotLight(sunsetMod*255,sunsetMod*255,0,xp*1.1,yp*1.1,zp,
            x,y,z, PI/6, 200);
  //white glow 
  lightSpecular(sunsetMod*255,sunsetMod*255,sunsetMod*205);
  spotLight(sunsetMod*255,sunsetMod*255,sunsetMod*205,xp,yp,zp,
            x,y,z, PI/12, 1000);
  
  //daylight
  lightSpecular(daylightMod*150,daylightMod*150,daylightMod*200);
  spotLight(daylightMod*255,daylightMod*255,daylightMod*255,xp,yp,zp*2,
            x,y,z*2, PI, 10);
}

void dayCycleBackground() {
  background(120*(0.5 + 0.5*(cos(2*PI*frameCount/15))),0,190*(1-(0.5 + 0.5*(cos(2*PI*frameCount/15)))));
}

void drawSun(float x, float y, float z) {
  pushMatrix();
      translate(x,y,z);
      fill(255,255,0);
      sphere(10);
    popMatrix();
}