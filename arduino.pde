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
    new Thread(this::ping).start(); //start the ping thread
    new Thread(this::joystickListener).start(); //start the listener thread for receiving input to prevent holding up the main thread
  }

  //ping the arduino every 1 second to keep the input going.
  //the arduino will not send any data if the last ping was 5 < seconds to prevent useless communication
  void ping() {
    while (true) {
      arduino.write(50); //write the ping command to the arduino
      delay(1000);
    }
  }


  /*
  If you hold the joystick, it will automatically spam the key according to the defined interval after and x amount of time.
  The function will compare two polls to detecting change in value to tell if an user holds a key
  */
  void joystickListener() {
    int dragTimeout = 400; //timeout before spamming the direction of the joystick
    int dragInterval = dragTimeout - 100; //the interval between spamming the joystick direction
    Joystick[] cached = new Joystick[joysticks.length]; //clone the joysticks to compare values
    long[][] cachedTime = new long[joysticks.length][2]; //saving the last time the joystick has moved to detect a hold
    for (int t = 0; t < joysticks.length; t++) {
      cached[t] = joysticks[t].clone();
      cachedTime[t] = new long[] {
        millis(), millis()
      };
    }

    while (true) {
      this.updateJoysticks(); //update the values to compare with the cloned ones
      Joystick cachejoystick;
      Joystick joystick;
      for (int t = 0; t < joysticks.length; t++) {
        cachejoystick = cached[t];
        joystick = joysticks[t];
        if (joystick.isButtonPressed() != cachejoystick.isButtonPressed() && !joystick.isButtonPressed()) {
          clickListener.onButtonClick(joystick.getId()); //fire the buttonclick event on the arduino thread
        }
        if (joystick.getX() != cachejoystick.getX() && joystick.getX() != 0) {
          moveListener.onChange(joystick.getId(), joystick.getX(), 0); //fire the change event on the arduino thread
        } else if (joystick.getX() != 0) {
          if (millis() - cachedTime[t][0] > dragTimeout) {
            cachedTime[t][0] = millis() - dragInterval; //if the delay of the holding joystick x-direction is longer then fire change event on the arduino thread and decrease the timeout by the interval delay
            moveListener.onChange(joystick.getId(), joystick.getX(), 0);  //fire change event on the arduino thread and decrease the timeout by the interval delay
          }
        } else if (joystick.getX() == 0) {
          cachedTime[t][0] = millis(); //reset the timing if the direction is reset to its x-center
        }

        if (joystick.getY() != cachejoystick.getY() && joystick.getY() != 0) {
          moveListener.onChange(joystick.getId(), 0, joystick.getY()); //fire change event on the arduino thread if the joystick direction has changed
        } else if (joystick.getY() != 0) {
          if (millis() - cachedTime[t][1] > dragTimeout) {
            cachedTime[t][1] = millis() - dragInterval; //if the delay of the holding joystick y-direction is longer then fire change event on the arduino thread and decrease the timeout by the interval delay
            moveListener.onChange(joystick.getId(), 0, joystick.getY()); //fire change event on the arduino thread and decrease the timeout by the interval delay
          }
        } else if (joystick.getY() == 0) {
          cachedTime[t][1] = millis(); //reset the timing if the direction is reset to its y-center
        }

        cached[t].update(joystick.getX(), joystick.getY(), joystick.isButtonPressed()); //update the first measured values to create a new comparing point
      }
    }
  }

  //update the joystick values and read the packet and clear the buffer to make sure the program receives the most recent newest controller changes
  void updateJoysticks() {
    //syncs the arduino thread to be able to read the buffer
    sync(()->{
      if (arduino.available() >= 2) {
        readPacket(); //read one of the two joysticks packets
        readPacket(); //read one of the two joysticks packets
        arduino.clear(); //clear the buffer to prevent overflow and potentional lag and out of sync exceptions
      }
    });
  }

  /*
  Read packet and decodes it according to the following model
  Packet construction:
    bit 7 & 6 = joystick id (left/right)
    bit 5 & 4 = x value
    bit 3 & 2 = y value
    bit 1     = reserved
    bit 0     = button pressed
  */
  void readPacket() {
    int packet = arduino.read(); //read the encoded/compressed packet
    int joystickId = (packet & 0b11000000) >> 6; //read the joystick id (left/right)
    int x = (packet & 0b00110000) >> 4; //read the joystick x-value
    int y = (packet & 0b00001100) >> 2; //read the joystick y-value
    int button = (packet & 0x01); //read the joystick button-value
    for (Joystick joystick: this.joysticks) {
      if (joystick.getId() == joystickId) {
        joystick.update(x, y, button == 1); //update the joystick with their corresponding id of the packet
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

  /*
  Parse the raw arduino encoded input to obtain the relative [-1,1] range together with the button.
  */
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
