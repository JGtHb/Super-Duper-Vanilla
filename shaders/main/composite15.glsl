#include "/lib/utility/util.glsl"
#include "/lib/structs.glsl"
#include "/lib/settings.glsl"

INOUT vec2 texcoord;

#ifdef VERTEX
    void main(){
        gl_Position = ftransform();
        texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    }
#endif

#ifdef FRAGMENT
    #if ANTI_ALIASING != 0
        uniform float viewWidth;
        uniform float viewHeight;
    #endif

    #if ANTI_ALIASING == 1
        const bool gcolorMipmapEnabled = true;

        #include "/lib/antialiasing/fxaa.glsl"
    #elif ANTI_ALIASING == 2
        const bool colortex6MipmapEnabled = true;
        const bool colortex6Clear = false;

        uniform sampler2D depthtex0;
        uniform sampler2D colortex6;

        /* Matrix uniforms */
        // View matrix uniforms
        uniform mat4 gbufferModelViewInverse;
        uniform mat4 gbufferPreviousModelView;

        // Projection matrix uniforms
        uniform mat4 gbufferProjectionInverse;
        uniform mat4 gbufferPreviousProjection;

        /* Position uniforms */
        uniform vec3 cameraPosition;
        uniform vec3 previousCameraPosition;

        #include "/lib/utility/convertPrevScreenSpace.glsl"

        #include "/lib/antialiasing/taa.glsl"
    #endif

    uniform sampler2D gcolor;

    void main(){
        #if ANTI_ALIASING == 1
            vec3 color = textureFXAA(gcolor, texcoord, vec2(viewWidth, viewHeight));
        #elif ANTI_ALIASING == 2
            vec3 color = textureTAA(gcolor, colortex6, texcoord, vec2(viewWidth, viewHeight));
        #else
            vec3 color = texture2D(gcolor, texcoord).rgb;
        #endif
        
    /* DRAWBUFFERS:0 */
        gl_FragData[0] = vec4(color, 1); //gcolor

        #if ANTI_ALIASING == 2
        /* DRAWBUFFERS:06 */
            gl_FragData[1] = vec4(color, 1); //colortex6
        #endif
    }
#endif