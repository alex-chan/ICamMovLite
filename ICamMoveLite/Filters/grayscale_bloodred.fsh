varying highp vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main()
{
    
    lowp vec3 pixcol = texture2D(inputImageTexture, textureCoordinate).rgb;
    mediump float lum = (pixcol.r + pixcol.g + pixcol.b) / 3.;
    
//    vec4 dst ;
    
    if(  pixcol.r >= 125./255. &&  ((pixcol.r - pixcol.g) >= 100./255.) && ((pixcol.r - pixcol.b ) >= 100./255. ) ){
        gl_FragColor = vec4(pixcol.r, lum, lum, 1.);
    }else{
        gl_FragColor = vec4(lum, lum, lum, 1.);
    }
    
    
    
}
    