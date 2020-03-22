
float map(float value, float min, float max, float min1, float max1){
  return ((value - min) * ((max1-min1)/(max-min)) + min1);
}

extern float r, g, b, r1, g1, b1;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){

  number x = texture_coords.x;
  number y = texture_coords.y;

  float rr = map(y, 0.0, 1.0, r, r1);
  float gg = map(y, 0.0, 1.0, g, g1);
  float bb = map(y, 0.0, 1.0, b, b1);

  return vec4(rr, gg, bb, 1.0);

}
