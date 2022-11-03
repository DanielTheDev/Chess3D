import java.util.*;
import ddf.minim.*;
import processing.serial.*;

Arduino arduino;
Board chessboard;
Map map;
Minim minim;
AudioPlayer song;


float movePiece = 0;

void setup() {
  size(1270, 720, P3D);
  arduino = new Arduino(this, this::onJoystickMove, this::onButtonClick);
  map = new Map();
  chessboard = new Board();
  surface.setTitle("3D Chess - By DanielTheDev");
  noCursor();
  frameRate(72);
  //minim = new Minim(this);
  //song = minim.loadFile("song.mp3");
  //song.loop();DanielKoopm
}

void draw() {
  pushMatrix();
  background(0);
  nextAnimation();
  ambientLight(255, 255, 255);
  map.drawCubeMap(pitch, yaw);
  chessboard.drawBoard();
  float move = -25 * (1 + sin(movePiece)) / 2;
  sync(() -> {
    if (chessboard.hasTileSelected()) chessboard.getSelectedPiece().moveVertically(move);
    chessboard.drawPieces();
    if (chessboard.hasTileSelected()) chessboard.getSelectedPiece().moveVertically(-move);
  });
  popMatrix();
}

public void onButtonClick(int id) {
  if (id == arduino.getLeftJoystick().getId()) {
    if (scene == CameraScene.FLOATING) {
      moveCameraTo(0.5 * HALF_PI, PI, 0, 0, -200, CameraScene.WHITE);
    } else {
      moveCameraTo(PI * 0.13369, startYaw, 0, 0, 0, CameraScene.FLOATING);
    }
  } else if (id == arduino.getRightJoystick().getId()) {
    sync(() -> {
       if (chessboard.hasPiece(chessboard.getCurrentTileX(), chessboard.getCurrentTileY(), PieceColor.WHITE)) {
        if (chessboard.getPiece(chessboard.getCurrentTileX(), chessboard.getCurrentTileY()).getPossiblePositions(chessboard).isEmpty()) return;
        chessboard.selectTile();
        movePiece = 0;
      }
      if (chessboard.hasTileSelected()) chessboard.selectMove(PieceColor.WHITE);
    });
  }
}

public void onJoystickMove(int id, int relX, int relY) {
  if (id == arduino.getRightJoystick().getId()) {
    chessboard.moveTile(relX, relY);
  }
}

public PShape loadModel(String path) {
  surface.setTitle("Loading model: " + path);
  return loadShape(path);
}

public synchronized void sync(Runnable runnable) {
  runnable.run();
}
