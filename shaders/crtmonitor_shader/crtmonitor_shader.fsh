//
// Simple passthrough fragment shader
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float progress; // Progress: 0.0 to 1.0
uniform float shutdown_progress; // Progress: 0.0 (screen on) to 1.0 (screen off)
uniform float scanline_count; // Number of scanlines ('0' means 'off')
uniform float green_levels; // Number of green values ('0' means 'full color')


// Get the color of the target pixel, based on the scaled source.
// Pixels outside the source area are rendered black.
vec3 raw(vec2 p)
{
    if (shutdown_progress == 0.0)
        return texture2D(gm_BaseTexture, p).rgb;
        
    // The x/y scale of the screen, calculated over time.
    vec2 scale = vec2(1.0) - vec2(smoothstep(0.15, 0.2, shutdown_progress), smoothstep(0.0, 0.2, shutdown_progress)) * 0.99;
    
    // Fade the color to white as time progresses...
    float whiteness = smoothstep(0.1, 0.3, shutdown_progress);
    
    // ...and fade to black as the cycle finishes.
    float bright = 1.0 - smoothstep(0.5, 1.0, shutdown_progress);

    vec2 srcXY = vec2(0.5 - (0.5 - p.x) / scale.x, 0.5 - (0.5 - p.y) / scale.y);
    if (srcXY.x < 0.0 || srcXY.x > 1.0 || srcXY.y < 0.0 || srcXY.y > 1.0)
    {
        // Outside source area - Use black.
        return vec3(0.0);
    }
    
    // Use the source data, applying a variable amount of whiteness.
    vec3 sourceRGB = texture2D(gm_BaseTexture, srcXY).rgb;
    return mix(sourceRGB, vec3(1.0), whiteness) * bright;
}

// Random number generator.
float rand(vec2 co)
{
    return fract(sin(dot(co, vec2(12.98, 78.2))) * 43758.5453);
}

// The equation of an ellipse.
float ellipse(vec2 xy, float r1, float r2)
{
    return pow(xy.x, 2.0) / pow(r1, 2.0) + pow(xy.y, 2.0) / pow(r2, 2.0) - 1.0;
}

// For a given point, how far within the screen bezel is it?
float calcBezelDepth(vec2 xy, float r1, float r2)
{
    return max(ellipse(xy, r2, r1), ellipse(xy, r1, r2)) / ellipse(vec2(0.5), r1, r2);
}

// Calculate the lighting effects to apply to the screen.
void screenShine(vec2 xy, inout vec3 rgb, float bevelDepth)
{
    float bright = smoothstep(1.0, 0.0, pow(distance(xy, vec2(0.1, 0.28)), 0.7));
    float shadow = smoothstep(0.51, 0.55, length(xy * vec2(0.5, 1.0) + vec2(0.0, 0.1)));
    
    rgb += (1.0 - rgb) * mix(0.0, 0.7, max(0.0, (bright - shadow) * progress));
}

// Apply a granular green tint to an rgb value.
void greenify(inout vec3 rgb)
{
    float luminosity = dot(rgb, vec3(0.299, 0.587, 0.114));
    rgb = mix(rgb, vec3(0.0, 1.2, 0.0) * floor(luminosity * green_levels) / green_levels, progress);
}

// Apply a sine wave travelling down the y axis to simulate scanlines.
void scanlines(inout vec3 rgb, vec2 p)
{
    float colorBoost = 0.5;
    rgb *= 1.0 + progress * (colorBoost - abs(sin(p.y * 3.14159 * scanline_count)));
}

// Darken the corners of the screen imply roundness.
void screenBulge(inout vec3 rgb, vec2 p)
{    
    float vignette = p.x * p.y * (1.0 - p.x) * (1.0 - p.y);
    rgb *= mix(1.0, pow(abs(32.0 * vignette), 0.35), progress);
}

// Apply a slight mottling effect to the rgb value.
// (Used to texture the bevel and screen 'glass'.)
void addNoise(inout vec3 rgb, vec2 p)
{
    rgb *= 1.0 - rand(p) * 0.1 * progress;
}

// Shader entry point.
void main()
{
    vec2 position = v_vTexcoord;
    vec2 xy = vec2(v_vTexcoord.x - 0.5, 0.5 - v_vTexcoord.y);

    // Define the shape of the screen bevel.    
    float r1 = mix(0.5, 0.47, progress);
    float r2 = mix(5.0, 1.4, progress);
    
    // Distort the screen pixels to give a 'bulge'.
    vec2 scaleXY = 0.5 * r2 / (r1 * vec2(sqrt((r2 + xy.y) * (r2 - xy.y)), sqrt((r2 + xy.x) * (r2 - xy.x))));
    vec2 bulgedXY = xy * scaleXY;

    vec3 rgb;
    float bevelDepth = calcBezelDepth(xy, r1, r2);
    if (bevelDepth > 0.0)
    {
         // Point is inside the bevel.
        vec3 bevelDark = vec3(0.1, 0.1, 0.05); // Bevel colors.
        vec3 bevelLight = vec3(1.0, 1.0, 0.9);
        
        rgb = mix(bevelDark, bevelLight, bevelDepth);
        addNoise(rgb, position); // Add texture to the bevel.
        
        
    }
    else
    {
        // 'Bulge' the screen.
        position = vec2(0.5 + bulgedXY.x, 0.5 - bulgedXY.y);
        
        // Get the source RGB pixel.
        rgb = raw(position);
        
        // Greenify?
        if (green_levels > 0.0)
            greenify(rgb);

        // Scanlines?
        if (scanline_count > 0.0)
            scanlines(rgb, position);

        // Apply screen effects.
    
        screenBulge(rgb, position);
        addNoise(rgb, position);
    }

    // The final pixel color.
    gl_FragColor = vec4(rgb, 1.0);
}

