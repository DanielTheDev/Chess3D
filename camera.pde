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

/*
Initialize a transition procedure by setting the starting variables and calculating the transforation coefficients for a smooth transition.
*/
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

/*
Perform the animation based on the coefficients calculated in the void::moveCameraTo() function.
*/
void nextAnimation() {
  if (isAnimating) {
    if (transformIndex < transformRange) {
      transformIndex++;
      yaw = startYaw + transformIndex * (float)(endYaw - startYaw) / transformRange; //Calculate the new yaw based on the time in the animation and sets the variable accordingly
      pitch = startPitch + transformIndex * (float)(endPitch - startPitch) / transformRange; //Calculate the new pitch based on the time in the animation and sets the variable accordingly
      translate(translationAddition[0] * transformIndex, translationAddition[1] * transformIndex, translationAddition[2] * transformIndex); //Calculate the physical position in the world by multiplying the delta position times the animationIndex
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
