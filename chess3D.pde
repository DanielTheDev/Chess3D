import java.util.*;
import ddf.minim.*;
import processing.serial.*;

Arduino arduino;
Board chessBoard;
Map map;
Minim minim;
AudioPlayer song;
AudioPlayer move;

void setup() {
  fullScreen(P3D);
  arduino = new Arduino(this, this::onJoystickMove, this::onButtonClick); //initialize the communication bridge between the arduino and the program
  map = new Map(); //load the cubemap of the envoirement
  chessBoard = new Board(); //load the board together with all the models required
  surface.setTitle("3D Chess - By DanielTheDev");
  noCursor();
  frameRate(72);
<<<<<<< HEAD
  minim = new Minim(this);
  song = minim.loadFile("sounds/song.mp3"); //load chess background music
  move = minim.loadFile("sounds/move.mp3"); //load chess piece move sound
  song.loop(); //set the background music on loop mode
=======
  //minim = new Minim(this);
  //song = minim.loadFile("song.mp3");
  //song.loop();
>>>>>>> 2813420e32c00b4ea9a848bab5bc6282f29fce6e
}

void draw() {
  nextAnimation(); //move the camera to the next step if animation transition is active
  ambientLight(255, 255, 255); //set the envoirementlight
  map.drawCubeMap(pitch, yaw); //draw the envoirement cube map (room)
  chessBoard.drawBoard(); //draw the board together with the selection marks
  if(chessBoard.hasTileSelected()) chessBoard.getSelectedPiece().nextAnimation(); //if player selected piece, the piece will iterate through animation
  sync(chessBoard::drawPieces); //draw all pieces in sync since the arduino thread will affect the pieces which is unsync, therefore it is import to sync both draw thread and arduino thread to avoid a ConcurrentModificationException
}

/*
Event listener method implemented from the JoystickClickListener
*/
public void onButtonClick(int id) {
  if (id == arduino.getLeftJoystick().getId()) {
    if (scene == CameraScene.FLOATING) {
      moveCameraTo(0.5 * HALF_PI, PI, 0, 0, -200, CameraScene.WHITE); //transition from floating perspective to the white perspective (viewpoint board)
    } else {
      moveCameraTo(PI * 0.13369, startYaw, 0, 0, 0, CameraScene.FLOATING); //transition from white perspective (viewpoint board) to the floating perspective
    }
  } else if (id == arduino.getRightJoystick().getId()) {
    sync(() -> {
       if (chessBoard.hasPiece(chessBoard.getCurrentTileX(), chessBoard.getCurrentTileY(), PieceColor.WHITE)) { //check if player select on of its own pieces
        if (chessBoard.getPiece(chessBoard.getCurrentTileX(), chessBoard.getCurrentTileY()).getPossiblePositions(chessBoard).isEmpty()) return; //if the piece has nowhere to go, prevent continuation
        chessBoard.selectTile(); //select the piece
      }
      if (chessBoard.hasTileSelected()) { 
        chessBoard.selectMove(PieceColor.WHITE); //if has selected, then move the piece to its desired destinated
      }
    });
  }
}

/*
Event listener method implemented from the JoystickMoveListener
*/
public void onJoystickMove(int id, int relX, int relY) {
  if (id == arduino.getRightJoystick().getId()) {
    chessBoard.moveTile(relX, relY); //change the selection tile to its relative location
  }
}

public synchronized void sync(Runnable runnable) {
  runnable.run(); //sync the caller thread
}
