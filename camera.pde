CameraScene scene = CameraScene.FLOATING;
CameraScene endScene = CameraScene.WHITE;

float startPitch;
float startYaw;
float endPitch;
float endYaw;
float pitch = PI * 0.13369;
float yaw;

float[] translationAddition = new float[3];

boolean isAnimating = false;
int transformIndex = 0;
int transformRange = 30;

void moveCameraTo(float pitch, float yaw, float x, float y, float z, CameraScene scene) {
  this.endScene = scene;
  this.scene = CameraScene.MOVING;
  this.startPitch = this.pitch;
  this.startYaw = this.yaw;
  this.endPitch = pitch;
  this.endYaw = yaw;
  this.translationAddition = new float[] {
    x / transformRange, y / transformRange, z / transformRange
  };
  this.transformIndex = 0;
  this.isAnimating = true;
}

void nextAnimation() {
  if (isAnimating) {
    if (transformIndex < transformRange) {
      transformIndex++;
      yaw = startYaw + transformIndex * (float)(endYaw - startYaw) / transformRange;
      pitch = startPitch + transformIndex * (float)(endPitch - startPitch) / transformRange;
      translate(translationAddition[0] * transformIndex, translationAddition[1] * transformIndex, translationAddition[2] * transformIndex);
    } else if (transformIndex == transformRange) {
      this.scene = endScene;
      isAnimating = false;
    }
  }

  if (scene == CameraScene.FLOATING) {
    yaw -= arduino.getLeftJoystick().getX() * 0.05 + 0.001;
    pitch = PI * 0.13369;
  } else if (scene == CameraScene.WHITE) {
    yaw = PI;
    pitch = 0.5 * HALF_PI;
    translate(0, 0, -200);
  }
  pitch %= TWO_PI;
  yaw %= TWO_PI;
}
