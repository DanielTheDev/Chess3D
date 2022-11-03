public enum PieceColor {

  WHITE,
  BLACK;

}

public enum CameraScene {

  FLOATING,
  WHITE,
  MOVING;

}

public enum PieceType {

  KING('K', "king") {
      public void setTranslation(PShape shape) {
        shape.translate(-2.833333, 0.3, 18.03333);
      }
    },
    QUEEN('Q', "queen") {
      public void setTranslation(PShape shape) {
        shape.translate(2.566666, 0, 18.566666);
      }
    },
    KNIGHT('N', "knight") {
      public void setTranslation(PShape shape) {
        shape.translate(13.033333, 0.05, 19.26666);
      }
    },
    BISHOP('B', "bishop") {
      public void setTranslation(PShape shape) {
        shape.translate(7.8, -0.23, 18.33333);
      }
    },
    ROOK('R', "rook") {
      public void setTranslation(PShape shape) {
        shape.translate(19.3333, 0.06, 18.8);
      }
    },
    PAWN('P', "pawn") {
      public void setTranslation(PShape shape) {
        shape.translate(18.95995, 0, 13.31666);
      }
    };

  private final char c;
  private final String name;

  public abstract void setTranslation(PShape shape);

  PieceType(char c, String name) {
    this.c = c;
    this.name = name;
  }

  public String getName() {
    return name;
  }

  public char getChar() {
    return c;
  }

  public static PieceType getByChar(char c) {
    for (PieceType type: values()) {
      if (type.c == c) return type;
    }
    return null;
  }
}
