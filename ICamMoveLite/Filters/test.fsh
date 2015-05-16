varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    lowp vec3 pixcol = texture2D(inputImageTexture, textureCoordinate).rgb;

    mediump float lum = (pixcol.r + pixcol.g + pixcol.b) / 3.0;    
    
    gl_FragColor = vec4(lum, lum, lum, 1.0);
}