class Arduino {
  private final String port = "COM4";
  private final Serial arduino;
  private final Joystick[] joysticks = new Joystick[] {
    new Joystick(1), new Joystick(2)
  };
  private final JoystickMoveListener moveListener;
  private final JoystickClickListener clickListener;

  public Arduino(chess3D instance, JoystickMoveListener moveListener, JoystickClickListener clickListener) {
    this.clickListener = clickListener;
    this.moveListener = moveListener;
    this.arduino = new Serial(instance, port, 9600);
    new Thread(this::ping).start();
    new Thread(this::joystickListener).start();
  }

  void ping() {
    while (true) {
      arduino.write(50);
      delay(1000);
    }
  }

  void joystickListener() {
    int dragTimeout = 400;
    int dragInterval = dragTimeout - 100;
    Joystick[] cached = new Joystick[joysticks.length];
    long[][] cachedTime = new long[joysticks.length][2];
    for (int t = 0; t < joysticks.length; t++) {
      cached[t] = joysticks[t].clone();
      cachedTime[t] = new long[] {
        millis(), millis()
      };
    }

    while (true) {
      this.updateJoysticks();
      Joystick cachejoystick;
      Joystick joystick;
      for (int t = 0; t < joysticks.length; t++) {
        cachejoystick = cached[t];
        joystick = joysticks[t];
        if (joystick.isButtonPressed() != cachejoystick.isButtonPressed() && !joystick.isButtonPressed()) {
          clickListener.onButtonClick(joystick.getId());
        }
        if (joystick.getX() != cachejoystick.getX() && joystick.getX() != 0) {
          moveListener.onChange(joystick.getId(), joystick.getX(), 0);
        } else if (joystick.getX() != 0) {
          if (millis() - cachedTime[t][0] > dragTimeout) {
            cachedTime[t][0] = millis() - dragInterval;
            moveListener.onChange(joystick.getId(), joystick.getX(), 0);
          }
        } else if (joystick.getX() == 0) {
          cachedTime[t][0] = millis();
        }

        if (joystick.getY() != cachejoystick.getY() && joystick.getY() != 0) {
          moveListener.onChange(joystick.getId(), 0, joystick.getY());
        } else if (joystick.getY() != 0) {
          if (millis() - cachedTime[t][1] > dragTimeout) {
            cachedTime[t][1] = millis() - dragInterval;
            moveListener.onChange(joystick.getId(), 0, joystick.getY());
          }
        } else if (joystick.getY() == 0) {
          cachedTime[t][1] = millis();
        }

        cached[t].update(joystick.getX(), joystick.getY(), joystick.isButtonPressed());
      }
    }
  }

  void updateJoysticks() {
    synchronized(chess3D.this) {
      if (arduino.available() >= 2) {
        readPacket();
        readPacket();
        arduino.clear();
      }
    }
  }

  void readPacket() {
    int packet = arduino.read();
    int joystickId = (packet & 0b11000000) >> 6;
    int x = (packet & 0b00110000) >> 4;
    int y = (packet & 0b00001100) >> 2;
    int button = (packet & 0x01);
    for (Joystick joystick: this.joysticks) {
      if (joystick.getId() == joystickId) {
        joystick.update(x, y, button == 1);
        break;
      }
    }
  }

  public Joystick getLeftJoystick() {
    return this.joysticks[1];
  }

  public Joystick getRightJoystick() {
    return this.joysticks[0];
  }
}

@FunctionalInterface
interface JoystickClickListener {

  void onButtonClick(int id);

}

@FunctionalInterface
interface JoystickMoveListener {

  void onChange(int id, int relX, int relY);

}

class Joystick {

  private final int id;
  private volatile int x;
  private volatile int y;
  private volatile boolean button;

  private Joystick(int id, int x, int y, boolean button) {
    this(id);
    this.x = x;
    this.y = y;
    this.button = button;
  }

  public Joystick(int id) {
    this.id = id;
  }

  public void update(int x, int y, boolean button) {
    this.x = x == 2 ? -1 : x;
    this.y = y == 2 ? -1 : y;
    this.button = button;
  }

  public int getId() {
    return this.id;
  }

  public int getX() {
    return this.x;
  }

  public int getY() {
    return this.y;
  }

  public boolean isButtonPressed() {
    return this.button;
  }

  public Joystick clone() {
    return new Joystick(id, x, y, button);
  }
}
