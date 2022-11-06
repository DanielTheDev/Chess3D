class Map {

  private final String[] mapRectangles = new String[] {
    "negy",
    "posy",
    "negx",
    "posx",
    "negz",
    "posz"
  };
  private final PImage[] map = new PImage[mapRectangles.length];
  private final String modelFolder = "models/map/";
  private final String pictureFormat = ".jpg";
  private final int mapScale = 3000; //size of the cubemap

  public Map() {
    for (int t = 0; t < mapRectangles.length; t++) {
      //load all the textures of the sides of the cubemap to be displayed
      map[t] = loadImage(modelFolder + mapRectangles[t] + pictureFormat);
    }
  }
  
  /*
  Draw all the sides of the cubemap with the corresponding camera pitch/yaw rotation
  */
  void drawCubeMap(float pitch, float yaw) {
    pushMatrix();
    translate(width / 2, height / 2, 0);
    rotateX(-pitch);
    rotateY(yaw);

    noStroke();
    textureMode(NORMAL);
    beginShape();
    texture(map[0]);
    vertex(mapScale, mapScale, mapScale, 1, 0);
    vertex(-mapScale, mapScale, mapScale, 0, 0);
    vertex(-mapScale, mapScale, -mapScale, 0, 1);
    vertex(mapScale, mapScale, -mapScale, 1, 1);
    endShape();

    beginShape();
    texture(map[1]);
    vertex(mapScale, -mapScale, mapScale, 1, 1);
    vertex(-mapScale, -mapScale, mapScale, 0, 1);
    vertex(-mapScale, -mapScale, -mapScale, 0, 0);
    vertex(mapScale, -mapScale, -mapScale, 1, 0);
    endShape();

    beginShape();
    texture(map[2]);
    vertex(-mapScale, mapScale, mapScale, 1, 1);
    vertex(-mapScale, -mapScale, mapScale, 1, 0);
    vertex(-mapScale, -mapScale, -mapScale, 0, 0);
    vertex(-mapScale, mapScale, -mapScale, 0, 1);
    endShape();

    beginShape();
    texture(map[3]);
    vertex(mapScale, mapScale, mapScale, 0, 1);
    vertex(mapScale, -mapScale, mapScale, 0, 0);
    vertex(mapScale, -mapScale, -mapScale, 1, 0);
    vertex(mapScale, mapScale, -mapScale, 1, 1);
    endShape();

    beginShape();
    texture(map[4]);
    vertex(mapScale, mapScale, -mapScale, 0, 1);
    vertex(-mapScale, mapScale, -mapScale, 1, 1);
    vertex(-mapScale, -mapScale, -mapScale, 1, 0);
    vertex(mapScale, -mapScale, -mapScale, 0, 0);
    endShape();

    beginShape();
    texture(map[5]);
    vertex(mapScale, mapScale, mapScale, 1, 1);
    vertex(-mapScale, mapScale, mapScale, 0, 1);
    vertex(-mapScale, -mapScale, mapScale, 0, 0);
    vertex(mapScale, -mapScale, mapScale, 1, 0);
    endShape();

    popMatrix();
  }

}
