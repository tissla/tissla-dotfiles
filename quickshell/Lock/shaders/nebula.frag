#version 440
layout(location = 0) in vec2 qt_TexCoord0;
layout(location = 0) out vec4 fragColor;
layout(std140, binding = 0) uniform buf {
    mat4 qt_Matrix;
    float qt_Opacity;
    float time;
    vec2 worldSize;
    vec2 viewportOrigin;
    vec2 viewportSize;
    vec2 textureExtent;
};
layout(binding = 1) uniform sampler2D source;

// A continuous flow field, rather than translating the entire picture.
// Coordinates and time are shared by all screens, including the deformation.
vec2 flow(vec2 p, float t) {
    vec2 broad = vec2(sin(p.y * 3.4 + p.x * 1.3 + t * 0.24),
                      cos(p.x * 3.1 - p.y * 1.1 - t * 0.19));
    vec2 curl = vec2(cos(p.y * 6.7 - p.x * 2.5 - t * 0.31),
                     sin(p.x * 5.3 + p.y * 3.8 + t * 0.27));
    return broad * 0.10 + curl * 0.045;
}

void main() {
    vec2 p = (viewportOrigin + qt_TexCoord0 * viewportSize) / worldSize.y;
    vec2 drift = flow(p, time);
    vec2 uvA = (p + drift) * worldSize.y / textureExtent;
    vec2 uvB = (p + flow(p + drift * 1.6 + vec2(0.17, -0.11), time + 9.0))
               * worldSize.y / textureExtent;
    vec3 a = texture(source, clamp(uvA, vec2(0.001), vec2(0.999))).rgb;
    vec3 b = texture(source, clamp(uvB, vec2(0.001), vec2(0.999))).rgb;
    float blend = 0.35 + 0.15 * sin(p.x * 3.7 + p.y * 2.1 - time * 0.18);
    vec3 gas = mix(a, b, blend);

    // Slow local colour and light changes travel through the gas, not the HUD.
    float warmth = 0.5 + 0.5 * sin(p.x * 2.5 - p.y * 3.0 + time * 0.16);
    vec3 tint = mix(vec3(0.78, 1.12, 1.10), vec3(1.35, 0.80, 1.10), warmth);
    float glow = 0.88 + 0.22 * sin(p.x * 4.0 + p.y * 5.0 - time * 0.22);
    fragColor = vec4(gas * tint * glow, 1.0) * qt_Opacity;
}
