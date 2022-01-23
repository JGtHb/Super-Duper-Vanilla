#include "/lib/utility/util.glsl"
#include "/lib/settings.glsl"

INOUT vec2 texcoord;

#ifdef VERTEX
    #if ANTI_ALIASING == 2
        /* Screen resolutions */
        uniform float viewWidth;
        uniform float viewHeight;

        #include "/lib/utility/taaJitter.glsl"
    #endif

    void main(){
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

        gl_Position = ftransform();

        #if ANTI_ALIASING == 2
            gl_Position.xy += jitterPos(gl_Position.w);
        #endif
    }
#endif

#ifdef FRAGMENT
    #ifdef VANILLA_SUN_MOON
        uniform sampler2D texture;
    #endif
    
    void main(){
        #ifdef VANILLA_SUN_MOON
        /* DRAWBUFFERS:2 */
            gl_FragData[0] = vec4(pow(texture2D(texture, texcoord).rgb, vec3(2.2)), 1); //colortex2
        #else
        /* DRAWBUFFERS:2 */
            gl_FragData[0] = vec4(0); //colortex2
        #endif
    }
#endif