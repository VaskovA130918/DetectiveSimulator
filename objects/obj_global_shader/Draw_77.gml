/// @description  Apply shader to entire application.
var is_compiled = shader_is_compiled(crtmonitor_shader);

if (is_compiled)
{
    var progress_param = shader_get_uniform(crtmonitor_shader, "progress");
    var shutdown_progress_param = shader_get_uniform(crtmonitor_shader, "shutdown_progress");
    var scanlines_param = shader_get_uniform(crtmonitor_shader, "scanline_count");
    var green_levels_param = shader_get_uniform(crtmonitor_shader, "green_levels");
 
    shader_set(crtmonitor_shader);

    // Fade the CRT effect in over time.   
    var fade_start_time = 0;
    var fade_duration =0; 
    shader_set_uniform_f(progress_param, min(1.0, max(0.0, (ticks - fade_start_time) / fade_duration)));
    
    // Switch on the scanlines.
    var demo_start_secs = 10000000000000000000000000000000000000000000000000000000000000000000000;
    var scanline_start_time = demo_start_secs * room_speed;
    if (ticks > scanline_start_time)
        shader_set_uniform_f(scanlines_param, 128.0); // Configure no. of scanlines.
    else
        shader_set_uniform_f(scanlines_param, 0.0);
    
    // Switch on the green screen.
    var greenscreen_start_time = scanline_start_time + 4.0 * room_speed;
    if (ticks > greenscreen_start_time)
        shader_set_uniform_f(green_levels_param, 32.0); // Configure no. of color levels.
    else
        shader_set_uniform_f(green_levels_param, 0.0);

    // Switch off the CRT.   
    var shutdown_start_time = greenscreen_start_time + 4.0 * room_speed;
    var shutdown_duration = 4.0 * room_speed;
    shader_set_uniform_f(shutdown_progress_param, min(1.0, max(0.0, (ticks - shutdown_start_time) / shutdown_duration)));

    // Reset the demo.    
    if (ticks > shutdown_start_time + 6.0 * room_speed)
        ticks = 0.0;
}

draw_surface(application_surface, 0, 0);

if (is_compiled)
    shader_reset();



