/// @description  Scale the application surface to the current display size.
if (surface_get_width(application_surface) != display_get_width())
    surface_resize(application_surface, display_get_width(), display_get_height()); 



/// Advance time.
ticks++;

