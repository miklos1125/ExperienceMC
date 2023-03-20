class Landscape extends Thread {
  byte[][][] block;
  int percent;

  Landscape(int xSize, int ySize, int zSize) {
    block = new byte[xSize][ySize][zSize];
    println(xSize + " " + ySize + " " + zSize);
  }

  private void createBlocks() {
    for (int x = 0; x < block.length; x++) {
      percent = (int)(x/(block.length*0.01));
      for (int z = 0; z < block[0][0].length; z++) {
        for (int y = 0; y < block[0].length; y++) {
          if (y==0) {
            block[x][y][z] = 1;
          } else if (y==1) {
            int number = 1+(int)(18*noise(x*0.01, 0, z*0.01)); //18
            for (int i = 0; i< number; i++) {
              block[x][y+i][z] = 2;
            }
          } else if (block[x][y][z]==0 && block[x][y-1][z]==2) {
            int number = (int)(3*noise(x*0.1, 0, z*0.1));
            for (int i = 0; i< number; i++) {
              block[x][y+i][z] = 3;
            }
          } else if (block[x][y][z]==0 && block[x][y-1][z]==3) {
            int number = (int)(7*noise(x*0.1, 0, z*0.1));
            if (number>2) {
              block[x][y][z] = 4;
            }
          } else if (y>=block[0].length-1) {
            int number = (int)(8*noise(x*0.1, y*0.5, z*0.1));
            block[x][y][z] = number > 4 ? (byte)6 : 0;
          }
        }
      }
    }
  }

  private void createTrees() {
    for (int x = 0; x < block.length; x++) {
      for (int z = 0; z < block[0][0].length; z++) {
        for (int y = 3; y < block[0].length; y++) {
          if (block[x][y][z]==4) {
            int number = (int)(9*noise(x*0.1, 0, z*0.1));
              if (number>5 && !forestFind(x, y, z)) {
              for (int i = 0; i<=number; i++) {
                block[x][y+i][z] = 10;
              }
              createLeaves(x,y+number,z);
            }
          }
        }
      }
    }
  }

  private boolean forestFind(int xpos, int ypos, int zpos) {
    for (int x = xpos-2; x <= xpos+2; x++) {
      if (x<0 || x>block.length-1) continue;
      for (int y = ypos-2; y <= ypos+2; y++) {
        for (int z = zpos-2; z <= zpos+2; z++) {
          if (z<0 || z>block[0][0].length-1 || (x==xpos && z==zpos)) continue;
          if (block[x][y][z] == 10) return true;
        }
      }
    }
    return false;
  }
  
  private void createLeaves(int xpos, int ypos, int zpos){
    block[xpos][ypos+1][zpos]= 11;
    for(int y = ypos; y>= ypos-1; y--){
      for(int x = xpos-1; x<= xpos+1; x++){
        if (x<0 || x>block.length-1) continue;
        for(int z = zpos-1; z<= zpos+1; z++){
          if (z<0 || z>block[0][0].length-1 || (x==xpos && z==zpos)) continue;
          block[x][y][z]=11;
        }
      }
    }
  }
  
  void createWater(){
    for (int x = 0; x < block.length; x++) {
      for (int z = 0; z < block[0][0].length; z++) {
        for (int y = 2; y < 12; y++) {
          if (block[x][y][z]==0 && block[x][y-1][z]==2) {
              block[x][y][z]=20;
              waterSpread(x, y, z);
          }
        }
      }
    }
  }
  
  void waterSpread(int xpos, int ypos, int zpos){
    for(int x = (xpos<=0 ? 0 : xpos-1); x < (xpos>=block.length ? block.length : xpos+1); x++){
      for(int z = (zpos<=0 ? 0 : zpos-1); z< (zpos>=block[0][0].length ? block[0][0].length : zpos+1); z++){
        if (block[x][ypos][z] == 0 || block[x][ypos][z] == 20){
          if(block[x][ypos-1][z] == 2 || block[x][ypos-1][z] == 20 || block[x][ypos-1][z] == 21){
            block[x][ypos][z] = 21;
            waterSpread(x, ypos, z);
          }
        }
      }
    }    
  }

  byte[][][] getLandscape() {
    println("Landscape given");
    return block;
  }

  void run() {
    createBlocks();
    createTrees();
    createWater();
    println("Landscape ready");
    creatingReady = true;
  }

  int getPercent() {
    return percent;
  }
}
