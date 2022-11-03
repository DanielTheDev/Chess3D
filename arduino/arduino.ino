long lastTime = 0;
int timeout = 5000;
int triggerMarge = 400;

int joystick1 = 1;
int joystick2 = 2;

int X1 = A0;
int X2 = A2;
int Y1 = A1;
int Y2 = A3;
int BTN_1 = 2;
int BTN_2 = 3;

void setup() {
  Serial.begin(9600);
  pinMode(X1, INPUT);
  pinMode(X2, INPUT);
  pinMode(Y1, INPUT);
  pinMode(Y2, INPUT);
  pinMode(BTN_1, INPUT_PULLUP);
  pinMode(BTN_2, INPUT_PULLUP);
}

void loop() {
  if(Serial.available() > 0) {
    int in = Serial.read();
    if(in == 50) {
      lastTime = millis();
    }
  }

  if((millis() - lastTime) < timeout) {
      int packet1 = createPacket(joystick1, analogRead(X1), analogRead(Y1), digitalRead(BTN_1));
      int packet2 = createPacket(joystick2, analogRead(X2), analogRead(Y2), digitalRead(BTN_2));
      Serial.write(packet1);
      Serial.write(packet2);
  }
}

int createPacket(int joystick, int x, int y, int button) {
  button = button == 1 ? 0 : 1;
  y = y < (500 - triggerMarge) ? 0x01 : (y > (500 + triggerMarge) ? 0x02 : 0x00);
  x = x < (500 - triggerMarge) ? 0x01 : (x > (500 + triggerMarge) ? 0x02 : 0x00);
  return (joystick << 6) | (x << 4) | (y << 2) | button;
}
