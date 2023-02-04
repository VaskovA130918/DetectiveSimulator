x =  mouse_x
y = mouse_y
speed = 15

delta_x = x-xprevious
delta_y = y-yprevious

if(mouse_check_button_pressed(mb_left)){
	audio_play_sound(Sound1, 1, false);
}

