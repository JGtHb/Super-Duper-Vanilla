vec3 basicShadingForward(in vec4 albedo){
	// Calculate sky diffusion first, begining with the sky itself
	vec3 totalDiffuse = toLinear(SKY_COLOR_DATA_BLOCK);

	#ifdef IS_IRIS
		// Calculate thunder flash
		totalDiffuse += lightningFlash;
	#endif

	#ifndef CLOUDS
		// Get sky light squared
		float skyLightSquared = squared(lmCoord.y);
		// Occlude the appled sky and thunder flash calculation by sky light amount
		totalDiffuse *= skyLightSquared;

		// Calculate block light
		totalDiffuse += toLinear(lmCoord.x * blockLightColor);
	#endif

	// Lastly, calculate ambient lightning
	totalDiffuse += toLinear(nightVision * 0.5 + AMBIENT_LIGHTING);

	#ifdef WORLD_LIGHT
		#ifdef CLOUDS
			float NLZ = dot(vertexNormal, vec3(shadowModelView[0].z, shadowModelView[1].z, shadowModelView[2].z));
		#endif

		#ifdef SHADOW_MAPPING
			// Get shadow pos
			vec3 shdPos = vec3(shadowProjection[0].x, shadowProjection[1].y, shadowProjection[2].z) * (mat3(shadowModelView) * vertexFeetPlayerPos + shadowModelView[3].xyz);
			shdPos.z += shadowProjection[3].z;

			// Apply shadow distortion and transform to shadow screen space
			shdPos = vec3(shdPos.xy / (length(shdPos.xy) * 2.0 + 0.2), shdPos.z * 0.1) + 0.5;

			#ifdef CLOUDS
				// Bias mutilplier, adjusts according to the current shadow resolution
				const vec3 biasAdjustMult = vec3(2, 2, -0.0625) * shadowMapPixelSize;

				// Since we already have NLZ, we just need NLX and NLY to complete the shadow normal
				float NLX = dot(vertexNormal, vec3(shadowModelView[0].x, shadowModelView[1].x, shadowModelView[2].x));
				float NLY = dot(vertexNormal, vec3(shadowModelView[0].y, shadowModelView[1].y, shadowModelView[2].y));

				// Apply normal based bias
				shdPos += vec3(NLX, NLY, NLZ) * biasAdjustMult;
			#else
				// Bias mutilplier, adjusts according to the current shadow resolution
				const float biasAdjustMult = 2.0 * shadowMapPixelSize;

				// Apply normal bias for particles and basic
				shdPos.y += shadowModelView[1].y * biasAdjustMult;
			#endif

			// Sample shadows
			#ifdef SHADOW_FILTER
				#if ANTI_ALIASING >= 2
					float blueNoise = fract(texelFetch(noisetex, ivec2(gl_FragCoord.xy) & 255, 0).x + frameFract);
				#else
					float blueNoise = texelFetch(noisetex, ivec2(gl_FragCoord.xy) & 255, 0).x;
				#endif

				vec3 shdCol = getShdCol(shdPos, blueNoise * TAU);
			#else
				vec3 shdCol = getShdCol(shdPos);
			#endif

			// Cave light leak fix
			float shdFactor = shdFade;

			#ifdef CLOUDS
				// Apply simple diffuse for clouds
				shdFactor *= max(0.0, NLZ * 0.6 + 0.4);
			#endif

			shdCol *= shdFactor;
		#else
			#ifdef CLOUDS
				// Apply simple diffuse for clouds
				float shdCol = max(0.0, NLZ * 0.6 + 0.4) * shdFade;
			#else
				// Sample fake shadows
				float shdCol = saturate(hermiteMix(0.96, 0.98, lmCoord.y)) * shdFade;
			#endif
		#endif

		#ifndef FORCE_DISABLE_WEATHER
			// Approximate rain diffusing light shadow
			float rainDiffuseAmount = rainStrength * 0.5;
			shdCol *= 1.0 - rainDiffuseAmount;

			#ifdef CLOUDS
				shdCol += rainDiffuseAmount;
			#else
				shdCol += rainDiffuseAmount * skyLightSquared;
			#endif
		#endif

		// Calculate and add shadow diffuse
		totalDiffuse += shdCol * toLinear(LIGHT_COLOR_DATA_BLOCK0);
	#endif

	// Return final result
	return albedo.rgb * totalDiffuse;
}