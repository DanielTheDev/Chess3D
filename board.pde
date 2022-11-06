public class Board {

  private final PShape board;
  private final PGraphics destinationTile;
  private final PGraphics selectionTile;
  private boolean hasTileSelected = false;
  private int selectionTileX;
  private int selectionTileY;
  private int selectedTileX = 1;
  private int selectedTileY = 1;

  private final List < Piece > pieces = java.util.Collections.synchronizedList(new ArrayList<>());

  private final char[][] format = new char[8][8];

  public Board() {
    this.board = loadShape("models/board/board.obj");
    this.board.rotateX(HALF_PI);
    this.board.scale(30);
    this.destinationTile = createTile(153, 51, 51);
    this.selectionTile = createTile(255, 255, 0);
    
    //Generates all the pieces for the board with respect to their location of the board
    //A bitmark is added if the piece is black and nothing if not
    format[0] = new char[] {'R'|0x80,'N'|0x80,'B'|0x80,'Q'|0x80,'K'|0x80,'B'|0x80,'N'|0x80,'R'|0x80};
    format[1] = new char[] {'P'|0x80,'P'|0x80,'P'|0x80,'P'|0x80,'P'|0x80,'P'|0x80,'P'|0x80,'P'|0x80};
    format[6] = new char[] {'P','P','P','P','P','P','P','P'};
    format[7] = new char[] {'R','N','B','K','Q','B','N','R'};
    
    //Generates a board out of the format template array
    for (int y = 0; y < 8; y++) {
      char[] row = format[y];
      for (int x = 0; x < 8; x++) {
        char type = row[x];
        boolean black = (type & 0x80) != 0;
        if (black) type = (char)(type & 0x7F);
        PieceType pieceType = PieceType.getByChar(type);
        if (pieceType == null) continue;
        pieces.add(new Piece(pieceType, black ? PieceColor.BLACK : PieceColor.WHITE, 8 - x, 8 - y));
      }
    }
  }
  
  /*
   Calculate the best move for the AI opponent and then moves the piece accordingly
   If the opponent can steal a piece from the enemy, it will prioritize this move.
  */
  public void moveOpponent() {
     List<Piece> blackPieces = getPieces(PieceColor.BLACK);
     if(blackPieces.isEmpty()) {
       exit();
     } else {
       java.util.Collections.shuffle(blackPieces);
       List<Piece> possibilities = blackPieces.stream().filter(piece->!piece.getPossiblePositions(this).isEmpty()).collect(java.util.stream.Collectors.toList());
       for(Piece piece : possibilities) {
           for(int[] loc : piece.getPossiblePositions(this)) {
             if(this.hasPiece(loc[0], loc[1], PieceColor.WHITE)) {
               pieces.remove(this.getPiece(loc[0], loc[1]));
               piece.move(loc[0], loc[1]);
               return;
             }
           }
       }
       for(Piece piece : possibilities) {
         for(int[] loc : piece.getPossiblePositions(this)) {
           piece.move(loc[0], loc[1]);
           return;
         }
       }
       exit();
     }
  }
  /*
  Draw all the remaining pieces of the board and displays their animation if neccesary  
  */
  public void drawPieces() {
    this.pieces.forEach(piece -> {
      float yAnimation = -25 * (1 + sin(piece.getAnimationIndex())) / 2; //Calcultes the animation y-value for the selected tile
      if(piece.getAnimationIndex() != 0) piece.moveVertically(yAnimation); //Applies the animation y-value if piece is selected
      pushMatrix();
      translate(162 * 3 + 162 / 2, 0, 162 * 3 + 162 / 2);
      translate(-162 * (piece.getX() - 1), 0, -162 * (8 - piece.getY()));
      shape(piece.getShape(), 0, 0); //Displays the piece
      popMatrix();
      if(piece.getAnimationIndex() != 0) piece.moveVertically(-yAnimation); //Applies the reversed animation y-value to prevent stacking tranlations
    });
  }
  
  /*
  Display a tile ligth at the location of the selected tile from the joystick
  This gives the tile a glowing effect that radiates to nearby pieces
  */
  public void displayTileLight(int r, int g, int b, int x, int y) {
    pointLight(r, g, b, 162 / 2 - x * 162 + 162 * 4, -50, 162 / 2 + y * 162 - 162 * 5);
  }

  /*
  Displays the tile and maps the tile location to a propper proportinal x- and y-value
  */
  public void displayTile(int x, int y, PGraphics mark) {
    int marge = 6;
    pushMatrix();
    translate((4 - x) * 162 - marge / 2, 10, (y - 5) * 162 - marge / 2);
    rotateX(HALF_PI);
    image(mark, 0, 0);
    popMatrix();
  }

  /*
  Creates a marked tile picture that can be drawn on the joystick selected location on the board.
  This tile is cached to prevent performance loss by drawing it multiple times
  */
  public PGraphics createTile(int red, int green, int blue) {
    int marge = 6;
    int stroke = 12;
    PGraphics mark = createGraphics(162 + marge, 162 + marge);
    mark.smooth();
    mark.beginDraw();
    mark.noFill();
    mark.stroke(red, green, blue);
    mark.strokeWeight(stroke);
    mark.rect(stroke, stroke, 162 - stroke * 2 + marge, 162 - stroke * 2 + marge);
    mark.filter(BLUR, 2);
    mark.strokeWeight(stroke * 0.8);
    mark.rect(stroke * 1.3, stroke * 1.3, 162 - stroke * 2 * 1.3 + marge, 162 - stroke * 2 * 1.3 + marge);
    mark.endDraw();
    return mark;
  }

  /*
  Check if the piece can perform the move and if so, take the opponents piece and psychically move the piece.
  If else, just move the piece
  */
  public boolean movePiece() {
    if (this.hasTileSelected()) {
      Piece piece = getSelectedPiece();
      if (piece.getPossiblePositions(this).stream().anyMatch(loc -> loc[0] == this.selectedTileX && loc[1] == this.selectedTileY)) {
        if (hasPiece(this.selectedTileX, this.selectedTileY)) {
          Piece otherpiece = getPiece(this.selectedTileX, this.selectedTileY);
          if (piece.canTake(otherpiece)) {
            pieces.remove(otherpiece);
            piece.resetAnimation();
            piece.move(this.selectedTileX, this.selectedTileY);
            return true;
          }
        } else {
          piece.resetAnimation();
          piece.move(this.selectedTileX, this.selectedTileY);
          return true;
        }
      }
    }
    return false;
  }
  
  /*
  Move your cursor around the board within the permitted area of 8x8
  */
  public void moveTile(int relX, int relY) {
    this.selectedTileX += relX;
    this.selectedTileY += relY;
    if (this.selectedTileX < 1) this.selectedTileX = 1;
    else if (this.selectedTileX > 8) this.selectedTileX = 8;
    if (this.selectedTileY < 1) this.selectedTileY = 1;
    else if (this.selectedTileY > 8) this.selectedTileY = 8;
  }

  public void unselectTile() {
    this.hasTileSelected = false;
  }

  public void selectTile() {
    this.selectionTileX = this.selectedTileX;
    this.selectionTileY = this.selectedTileY;
    this.hasTileSelected = true;
  }

  /*
  Select the move from your selected cursor on the board. If the move is allowed then it will proceed the move
  Then the opponent will respond right after that
  */
  public void selectMove(PieceColor side) {
    if (this.selectionTileX == this.selectedTileX && this.selectionTileY == this.selectedTileY) return;
    if (this.hasPiece(selectedTileX, selectedTileY, side)) return;
    if(this.movePiece()) {
      this.unselectTile();
      this.moveOpponent();
      move.rewind();
      move.play();
    }
  }

  public Piece getSelectedPiece() {
    return this.getPiece(this.selectionTileX, this.selectionTileY);
  }

  public boolean hasPiece(int x, int y, PieceColor pieceColor) {
    return pieces.stream().anyMatch(piece -> piece.getX() == x && piece.getY() == y && piece.getColor() == pieceColor);
  }

  public boolean hasPiece(int x, int y) {
    return pieces.stream().anyMatch(piece -> piece.getX() == x && piece.getY() == y);
  }

  public Piece getPiece(PieceType type, PieceColor pieceColor) {
    return pieces.stream().filter(piece -> piece.getType() == type && piece.getColor() == pieceColor).findFirst().orElse(null);
  }

  public Piece getPiece(int x, int y) {
    return pieces.stream().filter(piece -> piece.getX() == x && piece.getY() == y).findFirst().orElse(null);
  }
  
  public List<Piece> getPieces(PieceColor pieceColor) {
    return pieces.stream().filter(piece->piece.getColor() == pieceColor).collect(java.util.stream.Collectors.toList());
  }

  /*
  Draws the board with the tile light and the selected tile of the possible moves and the cursor
  */
  public void drawBoard() {
    translate(width / 2, height / 2, -400);
    rotateX(-pitch);
    rotateY(yaw);
    this.displayTileLight(204, 204, 0, this.selectedTileX, this.selectedTileY);
    shape(board, 0, 0);
    if (this.hasTileSelected) this.getSelectedPiece().getPossiblePositions(this).forEach(loc -> this.displayTile(loc[0], loc[1], this.getDestinationTile()));
    this.displayTile(this.selectedTileX, this.selectedTileY, this.getSelectionTile());
  }

  public PGraphics getDestinationTile() {
    return this.destinationTile;
  }

  public PGraphics getSelectionTile() {
    return this.selectionTile;
  }

  public boolean hasTileSelected() {
    return this.hasTileSelected;
  }

  public int getCurrentTileX() {
    return this.selectedTileX;
  }

  public int getCurrentTileY() {
    return this.selectedTileY;
  }
}
