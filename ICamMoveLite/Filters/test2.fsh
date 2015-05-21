varying highp vec2 textureCoordinate;
varying highp vec2 textureCoordinate2;
varying highp vec2 textureCoordinate3;



uniform sampler2D inputImageTexture;
uniform sampler2D inputImageTexture2;
uniform sampler2D inputImageTexture3;



void main()
{
    lowp vec3 pixcol = texture2D(inputImageTexture, textureCoordinate).rgb;
    lowp vec3 pixcol2 = texture2D(inputImageTexture2, textureCoordinate2).rgb;
    lowp vec3 pixcol3 = texture2D(inputImageTexture3, textureCoordinate3).rgb;
    
    lowp vec3 pix = (pixcol + pixcol2 + pixcol3 ) / 3. ;
    pix = mix( pix, vec3(1.) , 0.3);
    gl_FragColor = vec4( pix, 1.0);
    
    
}