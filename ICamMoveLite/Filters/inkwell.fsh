varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;

uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;

void main()
{
    lowp vec3 textureColor = texture2D(inputImageTexture, textureCoordinate).rgb;
    textureColor = vec3( dot(vec3(0.3, 0.6, 0.1), textureColor) );
    textureColor = vec3( texture2D(inputImageTexture2, vec2(textureColor.r, 0.16666)).r );
    
    gl_FragColor = vec4( textureColor, 1.0);
}