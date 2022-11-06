public class Piece {
  
  private final PShape shape;
  private final PieceType type;
  private final PieceColor pieceColor;
  private boolean moved = false;
  private volatile float animationIndex = 0;
  private int x;
  private int y;
  
  
  public Piece(PieceType type, PieceColor pieceColor, int x, int y) {
    this.type = type;
    this.pieceColor = pieceColor;
    this.x = x;
    this.y = y;
    this.shape = loadShape("models/"+pieceColor.name().toLowerCase()+"/"+type.getName()+"/"+type.getName()+".obj");
    this.shape.rotateX(HALF_PI);
    this.type.setTranslation(shape);
    if(pieceColor == PieceColor.BLACK) shape.rotateY(PI);
    this.shape.scale(type == PieceType.KING ? 25 : 30);
  }
  
  /*
  Calculate a list of the x- and y-values for the tiles the piece can move to
  All possibilities will be added and then trimmed based on the criteria filters
  */
  public List<int[]> getPossiblePositions(Board board) {
    List<int[]> positions = new ArrayList<>();
    if(this.type == PieceType.PAWN) {
      int direction = this.pieceColor == PieceColor.BLACK ? -1 : 1;
      if(board.hasPiece(this.x-1, this.y+direction)) positions.add(new int[] {this.x-1, this.y+direction});
      if(board.hasPiece(this.x+1, this.y+direction)) positions.add(new int[] {this.x+1, this.y+direction});
      if(!board.hasPiece(x, y+direction, this.getOppositeColor())) positions.add(new int[] {x, y+direction});
      if(!moved && !board.hasPiece(x, y+2*direction, this.getOppositeColor())) positions.add(new int[] {x, y+2*direction});
    } else if(type == PieceType.KING) {
      int[][] relativePositions = new int[][] {{1,1},{1,0},{0,1},{0,-1},{-1,0},{-1,-1},{1,-1},{-1, 1}};
      for(int[] pos : relativePositions) positions.add(new int[] {this.x + pos[0], this.y + pos[1]});
    } else if(type == PieceType.KNIGHT) {
      int[][] relativePositions = new int[][] {{1, 2}, {-1, 2}, {2, 1}, {-2, 1}, {-2, -1}, {2, -1}, {1, -2}, {-1, -2}};
      for(int[] pos : relativePositions) positions.add(new int[] {this.x + pos[0], this.y + pos[1]});
    } else if(type == PieceType.BISHOP) {
      this.addDiagonalDirections(board, positions);
    } else if(type == PieceType.ROOK) {
      this.addStraightDirections(board, positions);
    } else if(type == PieceType.QUEEN) {
      this.addStraightDirections(board, positions);
      this.addDiagonalDirections(board, positions);
    }
    positions.removeIf(this::isOutBound);
    positions.removeIf(coordinates -> {
      if(board.hasPiece(coordinates[0], coordinates[1])) {
        return board.getPiece(coordinates[0], coordinates[1]).getColor() == this.pieceColor;
      } else return false;
    });
    return positions;
  }
  
  /*
  Calculate all the relative tile locations to move to if the piece can move in straight directions
  */
  private void addStraightDirections(Board board, List<int[]> positions) {
    boolean top = false,right = false,bottom = false,left = false;
    for(int t = 1; t < 8; t++) {
      if(!top) {
        if(board.hasPiece(this.x, this.y + t)) top = true;
        positions.add(new int[] {this.x, this.y + t});
      }
      if(!bottom) {
        if(board.hasPiece(this.x, this.y -t)) bottom = true;
        positions.add(new int[] {this.x, this.y -t});
      }
      if(!left) {
        if(board.hasPiece(this.x - t, this.y)) left = true;
        positions.add(new int[] {this.x - t, this.y});
      }
      if(!right) {
        if(board.hasPiece(this.x + t, this.y)) right = true;
        positions.add(new int[] {this.x + t, this.y});
      }
    }
  }
  /*
  Calculate all the relative tile locations to move to if the piece can move in diagonal directions
  */
  private void addDiagonalDirections(Board board, List<int[]> positions) {
    boolean topleft = false,topright = false,bottomleft = false,bottomright = false;
    for(int t = 1; t < 8; t++) {
      if(!topleft) {
        if(board.hasPiece(this.x - t, this.y + t)) topleft = true;
        positions.add(new int[] {this.x - t, this.y + t});
      }
      if(!topright) {
        if(board.hasPiece(this.x + t, this.y + t)) topright = true;
        positions.add(new int[] {this.x + t, this.y + t});
      }
      if(!bottomleft) {
        if(board.hasPiece(this.x - t, this.y - t)) bottomleft = true;
        positions.add(new int[] {this.x - t, this.y - t});
      }
      if(!bottomright) {
        if(board.hasPiece(this.x + t, this.y - t)) bottomright = true;
        positions.add(new int[] {this.x + t, this.y - t});
      }
    }
  }
  
  public void resetAnimation() {
    this.animationIndex = 0;
  }
  
  /*
  Calculate the next animation value if the piece is selected.
  */
  public void nextAnimation() {
    this.animationIndex += PI / 60;
    this.animationIndex %= TWO_PI;
  }
  
  public float getAnimationIndex() {
    return this.animationIndex;
  }
  
  public void move(int x, int y) {
    this.moved = true;
    this.x = x;
    this.y = y;
  }
  
  public boolean canTake(Piece piece) {
    return piece.pieceColor != pieceColor;
  }
  
  public void moveVertically(float relY) {
    shape.translate(0, relY, 0);
  }
  
  private boolean isOutBound(int[] coordinate) {
    return coordinate[0] < 1 || coordinate[0] > 8 || coordinate[1] < 1 || coordinate[1] > 8;
  }

  public PieceType getType() {
    return type;
  }

  public PieceColor getColor() {
    return pieceColor;
  }
  
  public PieceColor getOppositeColor() {
    return pieceColor == PieceColor.WHITE ? PieceColor.BLACK : PieceColor.WHITE;
  }

  public int getX() {
    return x;
  }

  public int getY() {
    return y;
  }
  
  public PShape getShape() {
    return this.shape;
  }
}
