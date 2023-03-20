import java.awt.*;

final static int BLOCKNUMINAROW = 5000;
final static int SIGHT = 150;

Robot robot;
boolean up, down, left, right, forward, back;
boolean creatingReady;
int xCam, yCam, zCam;
int hurry;
float rad, rad2;

int blockSize;

byte[][][] block;
Landscape land;

void setup() {
 fullScreen(P3D);
  noCursor();
  rectMode(CENTER);
  strokeWeight(0.3);
  textAlign(CENTER);
  blockSize = 40;
  xCam = BLOCKNUMINAROW/2*blockSize;
  yCam = 20*blockSize;
  zCam = -50*blockSize;
  hurry = blockSize;
  rad=rad2=0;
  frameRate(10);
  try {
    robot = new Robot();
  }
  catch (AWTException e) {
    println("Robot is ill.");
  }
  robot.mouseMove(width/2, height/2);
  
  land = new Landscape(BLOCKNUMINAROW, 35, BLOCKNUMINAROW);
  land.start();
  block = land.getLandscape();
}

void draw() {
  if (!creatingReady) {
    background(0);
    stroke(255);
    noFill();
    rect(width/2, height/5, 400, 10);
    fill(255);
    rectMode(CORNER);
    rect(width/2-200, height/5-5, land.getPercent()*4, 10);
    rectMode(CENTER);
    textSize(36);
    text("Creating landscape...", width/2, height/5-30);
    text("Controls:", width/2, height/3);
    textSize(18);
    text("(Similar to Minecraft's spectator mode)\n\nmouse - turning around, look up & down\n\nw - foreward\ns - backwards\n"+
          "a - left\nd - right\n\nspace - up\nshift - down\ntab - go faster (keep pushing)\n\nesc - exit", width/2, height/2.5);
  } else {
    background(#95F7FA);
    camera(xCam, yCam, zCam, xCam+(blockSize*sin(rad)), yCam+(height/2-mouseY), zCam+(blockSize*cos(rad)), 0.0, -1.0, 0.0); //y+(200*sin(rad2))
    pushMatrix(); //Sun
      translate(xCam, yCam+1260, zCam+5000);
      noStroke();
      fill(255, 255, 22);
      ellipse(0, 0, 500, 500);
    popMatrix();
    pushMatrix(); //Moon
      translate(xCam, yCam+400, zCam-5000);
      fill(220);
      ellipse(0, 0, 500, 500);
    popMatrix();
    stroke(50); //Land
    
    for (int x = xStart(); x < xEnd(); x++) {
      for (int y = 0; y < block[0].length; y++) {
        for (int z = zStart(); z < zEnd(); z++) {

          if (block[x][y][z]!=0 && !beyondTheFrame(x,y,z) ) {
            pushMatrix();
            translate(x*blockSize, y*blockSize, z*blockSize);
            setColor(block[x][y][z]);
            if (block[x][y][z]==6 || block[x][y][z]==20 || block[x][y][z]==21) {
              rotateX(PI/2);
              noStroke();
              rect(0, 0, blockSize+1, blockSize);
              stroke(50);
            }else {
              box2(blockSize, x,y,z);
            }
            popMatrix();
          }
        }
      }
    }
    pushMatrix(); //Big black ground
      translate (xCam, -500, zCam);
      rotateX(HALF_PI);
      fill(30);
      circle(0, 0, 8000);
    popMatrix();
    updateCamera();
  }
}

void updateCamera() {
  if (up) yCam+=hurry;
  if (down) yCam-=hurry;
  if (yCam<=-180) yCam = -180;
  if (forward) {
    xCam+=(hurry*sin(rad));
    zCam+=(hurry*cos(rad));
  }
  if (back) {
    xCam-=(hurry*sin(rad));
    zCam-=(hurry*cos(rad));
  }
  if (right) {
    xCam+=(hurry*sin(rad+PI/2));
    zCam+=(hurry*cos(rad+PI/2));
  }
  if (left) {
    xCam+=(hurry*sin(rad-(PI/2)));
    zCam+=(hurry*cos(rad-(PI/2)));
  }
  rad = map(mouseX, 0, width, -PI, PI);
  //rad2 = map(mouseY,0,width, PI, -PI);
}

void keyPressed() {
  if (key==' ') {
    up = true;
  } else if (keyCode == SHIFT) {
    down = true;
  }
  if (keyCode==87) {
    forward = true;
  } else if (keyCode == 83) {
    back = true;
  }
  if (keyCode==65) {
    left = true;
  } else if (keyCode == 68) {
    right = true;
  }
  if (keyCode == 9) {
    hurry = 3*blockSize;
  }
}

void keyReleased() {
  if (key==' ') {
    up = false;
  } else if (keyCode == SHIFT) {
    down = false;
  }
  if (keyCode==87) {
    forward = false;
  } else if (keyCode == 83) {
    back = false;
  }
  if (keyCode==65) {
    left = false;
  } else if (keyCode == 68) {
    right = false;
  }
  if (keyCode == 9) {
    hurry = blockSize;
  }
}

void setColor(byte b) {
  switch(b) {
  case 1:
    fill(0);
    break;
  case 2:
    fill(204,194,134);
    break;
  case 3:
    fill(150, 75, 0);
    break;
  case 4:
    fill(0, 170, 0);
    break;
  case 5:
    fill(0, 255, 77);
    break;
  case 6:
    fill(255, 200);
    break;
  case 10:
    fill(#46411C);
   break;
  case 11:
    fill(120,150,30);
   break;
  case 20:
  case 21:
    fill(110,140,255,240);
  }
}

void mousePressed() {

  //  block[constrain((int)(x+(200*sin(rad))/50),0,block.length-1)][constrain((int)(y/50),0,block[0].length-1)][constrain((int)(z+(200*cos(rad))/50),0,block[0][0].length-1)] = 0;
}

void mouseMoved() {
  if (mouseX <=1) {
    robot.mouseMove(width-2, mouseY);
  } else if (mouseX >=width-1) {
    robot.mouseMove(2, mouseY);
  }
}

int xStart() {
  return (int)(xCam/blockSize) < SIGHT ? 0 : (int)(xCam/blockSize) >= block.length ? block.length-SIGHT : ((int)(xCam/blockSize))-SIGHT;
}

int xEnd() {
  return (int)(xCam/blockSize) < 0 ? SIGHT : (int)(xCam/blockSize) >= block.length-SIGHT ? block.length : ((int)(xCam/blockSize))+SIGHT;
}

int zStart() {
  return (int)(zCam/blockSize) < SIGHT ? 0 : (int)(zCam/blockSize) >= block[0][0].length ? block[0][0].length-SIGHT : ((int)(zCam/blockSize))-SIGHT; 
}

int zEnd() {
  return (int)(zCam/blockSize) < 0 ? SIGHT : (int)(zCam/blockSize) >= block[0][0].length-SIGHT ? block[0][0].length : ((int)(zCam/blockSize))+SIGHT; 
}

//boolean coveredOLDer(int xpos, int ypos, int zpos){
//  if(xpos-1 < 0 || xpos+1 >= block.length || ypos-1 < 0 || ypos+1 >= block[0].length || zpos-1 < 0 || zpos+1 >= block[0][0].length || block[xpos][ypos][zpos]==0) return false;
 
//  for(int y = ypos-1; y <= ypos+1 ;y++){
//    for(int x = (y == ypos ? xpos-1 : xpos); x < (y == ypos ? xpos+2 : xpos+1); x++){
//      for(int z = (y == ypos && x == xpos ? zpos-1 : zpos); z < zpos+2; z+=2){
//        if (block[x][y][z]==0 ) return false;
//        if (block[x][y][z]==11) return false;
//        if (block[x][y][z]==20 ) return false;
//      }
//    }
//  }
//  return true;
//}

//boolean coveredOLD(int xpos, int ypos, int zpos){
//  if(xpos-1 < 0 || xpos+1 >= block.length || ypos-1 < 0 || ypos+1 >= block[0].length || zpos-1 < 0 || zpos+1 >= block[0][0].length || block[xpos][ypos][zpos]==0) return false;
//  int xmod = ((xpos*blockSize) < xCam ? 1 : -1);
//  int ymod = ((ypos*blockSize) < yCam ? 1 : -1);
//  int zmod = ((zpos*blockSize) < zCam ? 1 : -1);
//  byte[]threeCovers ={block[xpos+xmod][ypos][zpos], block[xpos][ypos+ymod][zpos],  block[xpos][ypos][zpos+zmod]};
//  byte[]transparents = {0,6,11,20,21};
//  for(byte b: threeCovers){
//    for(byte bb: transparents){
//      if (b==bb) return false;
//    }
//  }
//  return true;
//}

boolean beyondTheFrame(int xpos, int ypos, int zpos){
  //if (screenZ(xpos*blockSize, ypos*blockSize, zpos*blockSize) < 0-blockSize/2 ) return true;
  if (screenX(xpos*blockSize, ypos*blockSize, zpos*blockSize) < 0-blockSize/2 || screenX(xpos*blockSize, ypos*blockSize, zpos*blockSize) > width+blockSize/2) return true;
  if (screenY(xpos*blockSize, ypos*blockSize, zpos*blockSize) < 0-blockSize/2  || screenY(xpos*blockSize, ypos*blockSize, zpos*blockSize) > height+blockSize/2) return true;
  return false;
}

void box2(int size, int xpos, int ypos, int zpos){
  int i = zCam<zpos*blockSize ? -1 : 1;
  if (isTransparent(xpos,ypos,zpos+i)){
    translate(0,0, i*size/2);
    rect(0,0,size, size);
    translate(0,0, -i*size/2); 
  }
  i = xCam<xpos*blockSize ? -1 : 1;
  if (isTransparent(xpos+i,ypos,zpos)){
    translate(i*size/2, 0, 0);
    rotateY(HALF_PI);
    rect(0,0,size, size);
    rotateY(-HALF_PI);
    translate(-i*size/2, 0, 0);
  }
  i = yCam<ypos*blockSize ? -1 : 1;
  if (isTransparent(xpos, ypos+i,zpos)){
    translate(0, i*size/2, 0);
    rotateX(HALF_PI);
    rect(0,0,size, size);
    rotateX(-HALF_PI);
    translate(0, -i*size/2, 0);
  }
}

boolean isTransparent(int xpos, int ypos, int zpos){
  if (xpos<0 || xpos>= block.length || ypos<0 || ypos>= block[0].length || zpos<0 || zpos>= block[0][0].length) return true;
  byte[]transparents = {0, 6, 20,21};
  for(byte b: transparents){
    if (block[xpos][ypos][zpos] == b) return true;
  }
  return false;
}
