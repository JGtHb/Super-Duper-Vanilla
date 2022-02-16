float lensFlareSimple(vec2 centerCoord, vec2 lightDir, float size, float dist){
    vec2 flareCoord = (centerCoord + lightDir * dist) * vec2(aspectRatio, 1);
    return squared(squared(saturate(1.0 - length(flareCoord) / size)));
}

float lensFlareRays(vec2 centerCoord, vec2 lightDir, float rayBeam, float size, float dist){
    vec2 flareCoord = (centerCoord + lightDir * dist) * vec2(aspectRatio, 1);
    float rays = max(0.0, sin(atan(flareCoord.x, flareCoord.y) * rayBeam));
    float lens = lensFlareSimple(centerCoord, lightDir, size, dist);
    return rays * lens + lens;
}

vec3 chromaLens(vec2 centerCoord, vec2 lightDir, float chromaDist, float size, float dist){
    return vec3(
        lensFlareSimple(centerCoord, lightDir, size, dist),
        lensFlareSimple(centerCoord, lightDir, size, dist * (1.0 - chromaDist)),
        lensFlareSimple(centerCoord, lightDir, size, dist * (1.0 - chromaDist * 2.0))
        );
}

vec3 getLensFlare(vec2 centerCoord, vec2 lightDir){
    float lens0 = lensFlareSimple(centerCoord, lightDir, 0.2, 0.75) * 0.125;
    float lens1 = lensFlareSimple(centerCoord, lightDir, 0.1, 0.5) * 0.125;
    float lens2 = lensFlareSimple(centerCoord, lightDir, 0.05, 0.25) * 0.125;
    float rays = lensFlareRays(centerCoord, lightDir, 8.0, 0.2, -1.0);
    vec3 chromaLens = chromaLens(centerCoord, lightDir, 0.05, 0.05, -0.5);
    return (lens0 + lens1 + lens2 + rays + chromaLens) * LENS_FLARE_BRIGHTNESS * sqrt(lightCol);
}