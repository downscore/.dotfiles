const float curvature_amount = 0.15; // Unusable outside approx [0, 1].

const float scanline_intensity = 0.1;  // [0, 1]. Higher is darker.
const float scanline_width = 2.0;  // Lower is bigger.
const float scanline_speed = 4.0;  // Higher is faster.

const float bloom_spread = 1.25;  // Larger is more spread out.
const float bloom_strength = 0.03;  // [0, 1]

// Golden spiral samples used for bloom.
//   [x, y, weight] weight is inverse of distance.
const vec3[24] bloom_samples = {
    vec3( 0.1693761725038636,  0.9855514761735895,  1),
    vec3(-1.333070830962943,   0.4721463328627773,  0.7071067811865475),
    vec3(-0.8464394909806497, -1.51113870578065,    0.5773502691896258),
    vec3( 1.554155680728463,  -1.2588090085709776,  0.5),
    vec3( 1.681364377589461,   1.4741145918052656,  0.4472135954999579),
    vec3(-1.2795157692199817,  2.088741103228784,   0.4082482904638631),
    vec3(-2.4575847530631187, -0.9799373355024756,  0.3779644730092272),
    vec3( 0.5874641440200847, -2.7667464429345077,  0.35355339059327373),
    vec3( 2.997715703369726,   0.11704939884745152, 0.3333333333333333),
    vec3( 0.41360842451688395, 3.1351121305574803,  0.31622776601683794),
    vec3(-3.167149933769243,   0.9844599011770256,  0.30151134457776363),
    vec3(-1.5736713846521535, -3.0860263079123245,  0.2886751345948129),
    vec3( 2.888202648340422,  -2.1583061557896213,  0.2773500981126146),
    vec3( 2.7150778983300325,  2.5745586041105715,  0.2672612419124244),
    vec3(-2.1504069972377464,  3.2211410627650165,  0.2581988897471611),
    vec3(-3.6548858794907493, -1.6253643308191343,  0.25),
    vec3( 1.0130775986052671, -3.9967078676335834,  0.24253562503633297),
    vec3( 4.229723673607257,   0.33081361055181563, 0.23570226039551587),
    vec3( 0.40107790291173834, 4.340407413572593,   0.22941573387056174),
    vec3(-4.319124570236028,   1.159811599693438,   0.22360679774997896),
    vec3(-1.9209044802827355, -4.160543952132907,   0.2182178902359924),
    vec3( 3.8639122286635708, -2.6589814382925123,  0.21320071635561041),
    vec3( 3.3486228404946234,  3.4331800232609,     0.20851441405707477),
    vec3(-2.8769733643574344,  3.9652268864187157,  0.20412414523193154)
};

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
  // Normalized screen coordinates [0, 1].
  vec2 uv = fragCoord / iResolution.xy;

  // Apply screen curvature - warp towards the outer edges of the screen.
  vec2 squared_dist_from_center = abs(0.5 - uv);
  squared_dist_from_center *= squared_dist_from_center;
  uv -= 0.5;
  uv.x *= 1.0 + (squared_dist_from_center.y * 0.3 * curvature_amount);
  uv.y *= 1.0 + (squared_dist_from_center.x * 0.4 * curvature_amount);
  uv += 0.5;

  // Set to black outside the boundaries.
  if (uv.y > 1.0 || uv.x < 0.0 || uv.x > 1.0 || uv.y < 0.0) {
    fragColor = vec4(0.0, 0.0, 0.0, 1.0);
    return;
  }

  // Get source colour after warping.
  vec3 source_color = texture(iChannel0, uv).rgb;

  // Scanline effect.
  float scanline = sin(uv.y * iResolution.y * scanline_width + iTime * scanline_speed) *
                   scanline_intensity + (1 - scanline_intensity);
  scanline = pow(scanline, 1.02);

  // Bloom effect.
  vec3 bloom_color = source_color;
  vec2 step = bloom_spread * vec2(1.414) / iResolution.xy;
  for (int i = 0; i < 24; i++) {
      vec3 bloom_sample = bloom_samples[i];
      vec3 neighbor = texture(iChannel0, uv + bloom_sample.xy * step).rgb;
      float luminance = 0.299 * neighbor.r + 0.587 * neighbor.g + 0.114 * neighbor.b;
      bloom_color += luminance * bloom_sample.z * neighbor * bloom_strength;
  }
  bloom_color = clamp(bloom_color, 0.0, 1.0);

  // Combine effects.
  vec3 final_color = bloom_color;
  final_color *= scanline;

  // Output to screen.
  fragColor = vec4(final_color, 1.0);
}
