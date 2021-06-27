#include "/lib/utility/util.glsl"
#include "/lib/structs.glsl"
#include "/lib/settings.glsl"

#include "/lib/globalVars/constants.glsl"
#include "/lib/globalVars/matUniforms.glsl"
#include "/lib/globalVars/posUniforms.glsl"
#include "/lib/globalVars/texUniforms.glsl"
#include "/lib/globalVars/timeUniforms.glsl"

#include "/lib/lighting/shdDistort.glsl"
#include "/lib/utility/texFunctions.glsl"

#include "/lib/vertex/vertexWave.glsl"

INOUT float blockId;

INOUT vec2 texcoord;

INOUT vec3 worldPos;
INOUT vec3 color;

#ifdef VERTEX
    attribute vec2 mc_midTexCoord;
    attribute vec4 mc_Entity;

    void main(){
        vec4 vertexPos = shadowModelViewInverse * (shadowProjectionInverse * ftransform());
        worldPos = vertexPos.xyz + cameraPosition;

        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
        blockId = mc_Entity.x;
        
        #ifdef ANIMATE
            getWave(vertexPos.xyz, worldPos, texcoord, mc_midTexCoord, mc_Entity.x, (gl_TextureMatrix[1] * gl_MultiTexCoord1).y);
        #endif

        gl_Position = shadowProjection * (shadowModelView * vertexPos);

        gl_Position.xyz = distort(gl_Position.xyz);

        #ifndef RENDER_FOLIAGE_SHD
            if(mc_Entity.x >= 10001 || mc_Entity.x <= 10004 || mc_Entity.x == 10007 || mc_Entity.x == 10008)
                gl_Position = vec4(10);
        #endif

        color.rgb = gl_Color.rgb;
    }
#endif

#ifdef FRAGMENT
    uniform sampler2D tex;

    void main(){
        vec4 shdColor = texture2D(tex, texcoord);
        shdColor.rgb *= color;

        #ifdef UNDERWATER_CAUSTICS
            int rBlockId = int(blockId + 0.5);
            float waterData = squared(1.0 - H2NWater(worldPos.xz).w) * 4.0;
            if(rBlockId == 10014) shdColor.rgb = shdColor.rgb * (1.0 + waterData);
        #endif

    /* DRAWBUFFERS:0 */
        gl_FragData[0] = shdColor;
    }
#endif