
vec2 blurCoordinates[5];

extern float blurAmount;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords){

  vec4 sum = vec4(0.0);

  blurCoordinates[0] = texture_coords.xy;
  blurCoordinates[1] = texture_coords.xy + blurAmount * 1.407333;
  blurCoordinates[2] = texture_coords.xy - blurAmount * 1.407333;
  blurCoordinates[3] = texture_coords.xy + blurAmount * 3.294215;
  blurCoordinates[4] = texture_coords.xy - blurAmount * 3.294215;

  sum += Texel(texture, blurCoordinates[0]) * 0.204164;
  sum += Texel(texture, blurCoordinates[1]) * 0.304005;
  sum += Texel(texture, blurCoordinates[2]) * 0.304005;
  sum += Texel(texture, blurCoordinates[3]) * 0.093913;
  sum += Texel(texture, blurCoordinates[4]) * 0.093913;

  return sum;

}
