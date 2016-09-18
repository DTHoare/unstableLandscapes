static class Math {
  
  /* -----------------------------------------------------------------------------
  periodicSigmoid
  ----------------------------------------------------------------------------- */
  
  //it transitions smoothly from 0 to magnitude as a sigmoid
  //higher transitionSpeed increases the speed from 0 to magnitude
  //period is the time between jumps
  static float periodicSigmoid(float t, float magnitude, float transitionSpeed, float period) {
    float y;
    y = magnitude;
    y /= (1+exp(-transitionSpeed*((t%period)-period/2)));
    return y;
  }
  
  /* -----------------------------------------------------------------------------
  dampedOscillation
  ----------------------------------------------------------------------------- */
  //gives organic movement
  //so that it bounces after each sigmoid
  //want a damped simple harmonic motion
  //starts at 1/2 period (time of sigmoid jump)
  static float dampedOscillation(float t_, float magnitude, float period) {
    float t = (t_+period/2) % (period);
    float revs = 2 * PI / period;
    float angle = magnitude * exp(-t*0.15) * sin(8 * t * revs);
    return (angle);
  }
  
  
  
}