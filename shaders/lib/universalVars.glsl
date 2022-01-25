#ifdef USE_SKY_LIGHT_AMOUNT
    const float eyeBrightFact = USE_SKY_LIGHT_AMOUNT;
#else
    float eyeBrightFact = eyeBrightnessSmooth.y / 240.0;
#endif

float torchBrightFact = eyeBrightnessSmooth.x / 240.0;

float newDawnDusk = smoothstep(0.32, 0.96, dawnDusk);
float newTwilight = cubed(twilight);

float newRainStrength = saturate(rainStrength * eyeBrightFact * float(isEyeInWater != 1));
float rainMult = newRainStrength + 1.0;
float underWaterMult = isEyeInWater + 1.0;

float ambientLighting = pow(AMBIENT_LIGHTING + nightVision * 0.5, GAMMA);

#ifdef ENABLE_LIGHT
    #ifdef USE_CUSTOM_LIGHTCOL
        vec3 lightCol = pow(USE_CUSTOM_LIGHTCOL, vec3(GAMMA)) * (1.0 - newTwilight);
    #else
        vec3 lightCol = pow(toneSaturation(mix(mix(vec3(LIGHT_NR, LIGHT_NG, LIGHT_NB) * LIGHT_NI, vec3(LIGHT_DR, LIGHT_DG, LIGHT_DB) * LIGHT_DI, day), vec3(LIGHT_DDR, LIGHT_DDG, LIGHT_DDB) * LIGHT_DDI, newDawnDusk) * 0.00392156863, 1.0 - rainStrength * 0.5), vec3(GAMMA)) * (1.0 - newTwilight);
    #endif
#endif

#if defined USE_CUSTOM_FOGCOL
    vec3 skyCol = pow(USE_CUSTOM_FOGCOL, vec3(GAMMA));
#elif defined USE_VANILLA_FOGCOL
    vec3 skyCol = pow(USE_VANILLA_FOGCOL, vec3(GAMMA));
#else
    #ifdef USE_SKY_LIGHT_AMOUNT
        vec3 skyCol = pow(toneSaturation(mix(mix(vec3(SKY_NR, SKY_NG, SKY_NB) * SKY_NI, vec3(SKY_DR, SKY_DG, SKY_DB) * SKY_DI, day), vec3(SKY_DDR, SKY_DDG, SKY_DDB) * SKY_DDI, newDawnDusk) * 0.00392156863, 1.0 - rainStrength * 0.5), vec3(GAMMA));
    #else
        vec3 skyCol = pow(toneSaturation(mix(mix(vec3(SKY_NR, SKY_NG, SKY_NB) * SKY_NI, vec3(SKY_DR, SKY_DG, SKY_DB) * SKY_DI, day), vec3(SKY_DDR, SKY_DDG, SKY_DDB) * SKY_DDI, newDawnDusk) * 0.00392156863, 1.0 - rainStrength * 0.5), vec3(GAMMA));
    #endif
#endif