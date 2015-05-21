precision mediump float;
varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform sampler2D inputImageTexture3;

void main()
{

    vec3 texel = texture2D(inputImageTexture, textureCoordinate).rgb;
    
    texel.r = texture2D(inputImageTexture3, vec2(texel.r, texel.r)).r;
    texel.g = texture2D(inputImageTexture3, vec2(texel.g, texel.g)).g;
    texel.b = texture2D(inputImageTexture3, vec2(texel.b, texel.b)).b;
    
    
    texel = vec3(
                 texture2D(inputImageTexture2, vec2(texel.r, .16666)).r,
                  texture2D(inputImageTexture2, vec2(texel.g, .5)).g,
                  texture2D(inputImageTexture2, vec2(texel.b, .83333)).b);


     gl_FragColor = vec4(texel, 1.0);
}