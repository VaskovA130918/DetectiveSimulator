if (obj_internet_img.script1 = 1){
	image_speed = 1
	if(!audio_is_playing(Sound2) and played =0){
	audio_play_sound(Sound2, 1, false);
	played=1
	}
}
	
	
	if(obj_enter_button.dialogue2_sent =1){
		image_speed=0
		image_index=0
		
	}