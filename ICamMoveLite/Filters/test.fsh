varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;
//uniform float texelWidth;
//uniform float texelHeight;
uniform highp float borderHeight;

void main()
{
    lowp vec3 pixcol = texture2D(inputImageTexture, textureCoordinate).rgb;

    mediump float lum = (pixcol.r + pixcol.g + pixcol.b) / 3.0;
    
    
    if (textureCoordinate.y <= borderHeight || textureCoordinate.y >= 1.0 - borderHeight) {
        gl_FragColor = vec4( vec3(0.), 1.0);
    }else{
        gl_FragColor = vec4(lum, lum, lum, 1.0);    
    }
    
    
}