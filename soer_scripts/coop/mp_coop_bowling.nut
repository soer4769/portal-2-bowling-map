// --------------------------------------------------------
// Global variables
// --------------------------------------------------------

// Shot information
shot_number								<- 0
shot_pins								<- 0
shot_points								<- [0, 0, 0]

// Round information
round_number 							<- 0
round_player_is_blue 					<- true

// Current game player round points
player_blue_points 						<- [[[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0, 0], 0]]
player_orange_points 					<- [[[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0], 0], [[0, 0, 0], 0]]

// Game score scoreboard drawing
player_special_types					<- [0, 0]
player_draw_on_screen					<- [[], []]
player_bonus_access						<- [0, 0]

// Global games information
game_number								<- -1
game_winner								<- -1
game_started							<- false
game_locked								<- false
game_autonew							<- false

// Static global game points
game_draw								<- 0
game_won								<- [0, 0]
game_strikes							<- [0, 0]
game_spares								<- [0, 0]
game_misses								<- [0, 0]
game_points								<- [0, 0]

// Global Game player Achievements data
achievement_win_a_game					<- [0, 0]
achievement_win_two_games_in_a_row		<- [0, 0]
achievement_lose_a_game					<- [0, 0]
achievement_lose_two_games_in_a_row		<- [0, 0]
achievement_knock_down_a_pin			<- [0, 0]
achievement_knock_down_multiple_pins	<- [0, 0]
achievement_miss_any_pins_in_a_shot		<- [0, 0]
achievement_miss_a_frame				<- [0, 0]
achievement_make_an_open_frame			<- [0, 0]
achievement_get_a_spare					<- [0, 0]
achievement_get_two_spares_in_a_row		<- [0, 0]
achievement_get_four_spares_in_a_row	<- [0, 0]
achievement_win_a_game_without_spares	<- [0, 0]
achievement_get_a_strike				<- [0, 0]
achievement_get_two_strikes_in_a_row	<- [0, 0]
achievement_get_four_strikes_in_a_row	<- [0, 0]
achievement_get_six_strikes_in_a_row	<- [0, 0]
achievement_get_eight_strikes_in_a_row	<- [0, 0]
achievement_get_ten_strikes_in_a_row	<- [0, 0]
achievement_make_a_perfect_game			<- [0, 0]
achievement_win_a_game_without_strikes	<- [0, 0]
achievement_use_the_secret_in_a_game	<- [0, 0]

// Game Achievement variables
av_games_won_in_a_row					<- [0, 0]
av_spares_in_a_row						<- [0, 0]
av_strikes_in_a_row						<- [0, 0]
av_strikes_in_a_game					<- [0, 0]
av_spares_in_a_game						<- [0, 0]

// Debugging data
debug									<- false

// --------------------------------------------------------
// LogToConsole - Prints a message to the console
// --------------------------------------------------------
function log_to_console(arg){
	
	// If debug is on
	if(debug){
		printl(arg)
	}
	
	// If debug is off
	else {
		return false
	}
}

// --------------------------------------------------------
// ToggleDebug - Toggles debugging mode
// --------------------------------------------------------
function toggle_debug(){
	
	// Toggles debugging
	debug = !debug
	
	// Logs the current debugging state regardless of its state
	printl("mp_coop_bowling.nut -> ToggleDebug() -> \"Debugstate: " + debug + "\" \n")
}

// --------------------------------------------------------
// new_game - Starts a new game by resetting all of the games variables (except global information)
// --------------------------------------------------------
function new_game(){
	
	// Starts a new game if the current one is not locked or the upcomming game is locked beforehand
	if(!game_locked || !game_started && game_locked){
	
		game_number++
		
		game_started = true
		
		if(game_number > 0){
			reset_game()
		}
		
		log_to_console("\n")
		log_to_console("|----------------------------------------------------------------------------------")
		log_to_console("| New Game Starting - Game number: " + (game_number + 1))
		log_to_console("|----------------------------------------------------------------------------------")
		log_to_console("| Round:  " + (round_number + 1) + "/10")
		log_to_console("| Player: " + (round_player_is_blue ? "Blue" : "Orange"))
		log_to_console("| Shot:   " + (shot_number + 1))
		log_to_console("|----------------------------------------------------------------------------------")
		
		EntFire("@music_normal", "PlaySound", "", 0)
		
		EntFire("@map_setup", "trigger", "", 0)
		EntFire("@ball_lane_trigger", "Enable", "", 0)
		EntFire("@secret_trigger", "Enable", "", 0)
		
		EntFire("@turret", "Kill", "", 0)
		EntFire("@turret_template", "ForceSpawn", "", 2)
		
		EntFire("round_points_scored_text", "SetText", "Round " + (round_number + 1) + "/10", 0)
		EntFire("round_points_scored_text", "Display", "", 0)
		
		EntFire("round_points_scored_text", "SetText", "Blue turn", 4)
		EntFire("round_points_scored_text", "Display", "", 4)
	}
}

// --------------------------------------------------------
// end_game - Ends the current game by finding the winning player of the current game (or draw)
// --------------------------------------------------------
function end_game(){
	
	// Finds each players total game points
	local player_blue_total_points	 	= get_player_total_points(true)
	local player_orange_total_points 	= get_player_total_points(false)
	
	log_to_console("|----------------------------------------------------------------------------------")
	
	// If blue got the most points
	if(player_blue_total_points > player_orange_total_points){
	
		log_to_console("| Game Ending - Winner: blue")
	
		game_won[0] += 1
		game_winner = 0
		EntFire("end_game_text", "SetText", "Blue wins with " + (player_blue_total_points - player_orange_total_points) + " points!", 0)
	}
	
	// If orange got the most points
	else if(player_blue_total_points < player_orange_total_points){
	
		log_to_console("| Game Ending - Winner: orange")
	
		game_won[1] += 1
		game_winner = 1
		EntFire("end_game_text", "SetText", "Orange wins with " + (player_orange_total_points - player_blue_total_points) + " points!", 0)
	}
	
	// If both players got the same number of points
	else {
		log_to_console("| Game Ending - Winner: draw")
		
		game_draw++
		game_winner = 2
		EntFire("end_game_text", "SetText", "Draw with " + player_blue_total_points + " points each!", 0)
	}
	
	log_to_console("|----------------------------------------------------------------------------------")
	log_to_console("| Blue Total Points:   " + get_player_total_points(true))
	log_to_console("| Orange Total Points: " + get_player_total_points(false))
	log_to_console("|----------------------------------------------------------------------------------")
	
	check_for_achievements("endgame")
	screen_show_game_numbers("endgame")
	
	log_to_console("|----------------------------------------------------------------------------------")
	
	reset_previous_game_screen()
	screen_show_previous_game()
	
	log_to_console("|----------------------------------------------------------------------------------")
	
	EntFire("end_game_text", "Display", "", 0)
	EntFire("@ball_lane_trigger", "Disable", "", 0)
	EntFire("@secret_trigger", "Disable", "", 0)
	EntFire("@music_final_round", "StopSound", "", 0)
	EntFire("@ball_lane_trigger","Disable","",0)
	
	game_started 	= false
	game_locked 	= 0
	
	// Autostarts a new game if the players have chosen to do so
	if(game_autonew){
		EntFire("bowling_script", "RunScriptCode", "new_game()", 10)
		EntFire("round_points_scored_text", "SetText", "Autostarting new game", 0)
		EntFire("round_points_scored_text", "Display", "", 5)
	}
}

// --------------------------------------------------------
// next_shot - Looks for the number of shots the player has left in the round
// --------------------------------------------------------
function next_shot(){

	if(game_started){
		
		check_shot_type()
		check_bonus_points()
		display_shot_points()
		screen_show_shot_points()
		screen_show_game_numbers("shot")
		check_for_achievements("shot")
		check_shot_pins()
		
		// If the current player got a strike in first shot in the current round
		if(shot_number < 1 && !shot_is_strike()){
		
			shot_number++
			log_to_console("| Shot: " + (shot_number + 1))
		}
		
		// If it is the last round and the current player have got access got the bonus shot, by either getting a strike or a spare beforehand in that round
		else if(round_number == 9 && shot_number < 2
		&& (shot_points[0] == 10 || shot_points[1] == 10 || (shot_points[0] + shot_points[1]) == 10)){
			
			local screen_player = round_player_is_blue ? 0 : 1
			
			shot_number++
			log_to_console("| Shot: " + (shot_number + 1))
			
			if(player_bonus_access[screen_player] == 0){
				player_bonus_access[screen_player] = 1
			}
			
			EntFire("@turret", "Kill", "", 0)
			EntFire("@turret_template", "ForceSpawn", "", 2)
		}
		
		// If the current player has shot all the shots avaliable for the current round
		else {
			next_player()
		}
	}
}

// --------------------------------------------------------
// next_player - Sums up the current players round and changes player / round or ends the game if necessary
// --------------------------------------------------------
function next_player(){
	
	add_round_points()
	reset_shot()
	screen_show_round_points()
	
	// if it was anything than the last round by orange (last round in the game)
	if(round_number < 9 
	|| round_number == 9 && round_player_is_blue){
	
		round_player_is_blue = !round_player_is_blue
		
		if(round_player_is_blue){
		
			next_round()
			
			EntFire("round_points_scored_text", "SetText", "Blue turn", 4)
			EntFire("round_points_scored_text", "Display", "", 4)
		}
		
		else {
			
			EntFire("round_points_scored_text", "SetText", "Orange turn", 2)
			EntFire("round_points_scored_text", "Display", "", 2)
		}
		
		log_to_console("|----------------------------------------------------------------------------------")
		log_to_console("| Player: " + (round_player_is_blue ? "Blue" : "Orange"))
		log_to_console("|----------------------------------------------------------------------------------")
		log_to_console("| Shot: " + (shot_number + 1))
		
		EntFire("@turret", "Kill", "", 0)
		EntFire("@turret_template", "ForceSpawn", "", 2)
	}
	
	// If it was the last round in the game
	else {
		end_game()
	}
}

// --------------------------------------------------------
// next_round - Changes and displays the next round
// --------------------------------------------------------
function next_round(){
	
	round_number++
	
	EntFire("texture_toggle_current_game", "SetTextureIndex", (round_number + 5), 2)
	EntFire("round_points_scored_text", "SetText", "Round " + (round_number + 1) + "/10", 2)
	EntFire("round_points_scored_text", "Display", "", 2)
	
	log_to_console("|----------------------------------------------------------------------------------")
	log_to_console("| Round: " + (round_number + 1) + "/10")
	
	if(round_number == 9){
		EntFire("@music_normal", "StopSound", "", 0)
		EntFire("@music_final_round", "PlaySound", "", 1)
	}
}

// --------------------------------------------------------
// reset_shot - Resets the shot data by the previous player
// --------------------------------------------------------
function reset_shot(){
	shot_number = shot_pins = shot_points[0] = shot_points[1] = shot_points[2] = 0
}

// --------------------------------------------------------
// reset_game - Resets the current game options
// --------------------------------------------------------
function reset_game(){
	
	round_number 			= 0
	round_player_is_blue 	= true
	game_winner				= -1
	player_bonus_access		= [0, 0]

	reset_shot()
	reset_screen()
	reset_achievements_variables()
	
	foreach(index, rounds in player_blue_points){
		foreach(number, pins in player_blue_points[index][0]){
			player_blue_points[index][0][number] = 0
		}
		
		player_blue_points[index][1] = 0
	}
	
	foreach(index, rounds in player_orange_points){
		foreach(number, pins in player_orange_points[index][0]){
			player_orange_points[index][0][number] = 0
		}
		
		player_orange_points[index][1] = 0
	}
}

// --------------------------------------------------------
// reset_total - Resets all game variables avaliable
// --------------------------------------------------------
function reset_total(){

	game_number	= -1
	game_draw	= 0
	game_won 	= game_strikes = game_spares = game_misses = game_points = [0, 0]

	reset_game()
	reset_achievements_total()
	reset_previous_game_screen()
	reset_game_numbers_screen()
}

// --------------------------------------------------------
// reset_screen - Resets the in-game player point screen
// --------------------------------------------------------
function reset_screen(){
	
	EntFire("texture_toggle_current_game", "SetTextureIndex", 5, 0)

	for(local j = 1; j <= 2; j++){
		for(local i = 1; i <= 10; i++){
			for(local y = 1; y <= 3; y++){

				if(y < 3 || i == 10 && y == 3){
					EntFire("signage_w" + j + "_s" + y + "_r" + i, "Disable", "", 0)
				}
				
				EntFire("points_w" + j + "_r" + i + "_p" + y, "Disable", "", 0)
			}
		}
	}
}

// --------------------------------------------------------
// reset_achievements_screen - Resets the in-game player achievement screen
// --------------------------------------------------------
function reset_achievements_screen(){
	
	for(local r = 1; r <= 4; r++){
		for(local w = 1; w <= 2; w++){
			for(local s = 1; s <= 6; s++){
				
				if(!(s > 4 && r == 4)){
					EntFire("achievement_toggle_w" + w + "_s" + s + "_r" + r, "SetTextureIndex", "0", 0)
				}
			}
		}
	}
}

// --------------------------------------------------------
// reset_previous_game_screen - Resets the in-game previous game screen
// --------------------------------------------------------
function reset_previous_game_screen(){
	
	EntFire("texture_toggle_previous_game_screen", "SetTextureIndex", 5, 0)
	
	for(local j = 1; j <= 2; j++){
		for(local i = 1; i <= 10; i++){
			for(local y = 1; y <= 3; y++){

				if(y < 3 || i == 10 && y == 3){
					EntFire("pre_signage_w" + j + "_s" + y + "_r" + i, "Disable", "", 0)
				}
				
				EntFire("pre_points_w" + j + "_r" + i + "_p" + y, "Disable", "", 0)
			}
		}
	}
	
	for(local r = 1; r <= 4; r++){
		for(local s = 1; s <= 3; s++){
			EntFire("pre_won_signage_s" + s + "_r" + r, "Disable", "", 0)
		}
	}
}

// --------------------------------------------------------
// reset_game_numbers_screen - Resets the game in numbers screen
// --------------------------------------------------------
function reset_game_numbers_screen(){
	
	for(local w = 0; w <= 2; w++){
		for(local r = 1; r <= 5; r++){
			for(local s = 1; s <= 6; s++){
				if((r < 5 && s <= 3 || r == 5) && s > 1){
					EntFire("number_points_w" + w + "_s" + s + "_r" + r, "Disable", "", 0)
				}
				
				else if(s == 1){
					EntFire("number_texture_toggle_w" + w + "_s" + s + "_r" + r, "SetTextureIndex", "0", 0)
				}
			}
		}
	}
}

// --------------------------------------------------------
// reset_achievements_variables - Resets the current game specific achievement variables
// --------------------------------------------------------
function reset_achievements_variables(){
	av_games_won_in_a_row = av_spares_in_a_row = av_strikes_in_a_row = av_strikes_in_a_game = av_spares_in_a_game = [0, 0]
}

// --------------------------------------------------------
// reset_achievements_total - Resets all achievements by both players
// --------------------------------------------------------
function reset_achievements_total(){
	
	achievement_win_a_game = achievement_win_two_games_in_a_row = achievement_lose_a_game = achievement_lose_two_games_in_a_row =  achievement_knock_down_a_pin = achievement_knock_down_multiple_pins = achievement_miss_any_pins_in_a_shot = achievement_miss_a_frame = achievement_make_an_open_frame = achievement_get_a_spare = achievement_get_two_spares_in_a_row = achievement_get_four_spares_in_a_row = achievement_win_a_game_without_spares = achievement_get_a_strike = achievement_get_two_strikes_in_a_row = achievement_get_four_strikes_in_a_row = achievement_get_six_strikes_in_a_row = achievement_get_eight_strikes_in_a_row = achievement_get_ten_strikes_in_a_row = achievement_make_a_perfect_game = achievement_win_a_game_without_strikes = achievement_use_the_secret_in_a_game = [0, 0]
	
	reset_achievements_screen()
}

// --------------------------------------------------------
// display_shot_points - Displays the points the player got in the given shot
// --------------------------------------------------------
function display_shot_points(){
	
	local round_current_player = round_player_is_blue ? "Blue" : "Orange"
	
	if(shot_is_strike()){
		EntFire("round_points_scored_text", "SetText", "Strike", 0)
		EntFire("@strike", "PlaySound", "", 0)
		EntFire("strike_particles", "Start", "", 0)
		EntFire("strike_particles", "Stop", "", 2)
	}
	
	else if(shot_is_spare()){
		EntFire("round_points_scored_text", "SetText", "Spare", 0)
	}
	
	else if(shot_is_miss()){
		EntFire("round_points_scored_text", "SetText", "Miss", 0)
	}
	
	else {
		local word_ending = shot_points[shot_number] < 2 ? "" : "s"
		
		EntFire("round_points_scored_text", "SetText", round_current_player + " scored " + shot_points[shot_number] + " point" + word_ending, 0)
	}
	
	EntFire("round_points_scored_text", "Display", "", 0)
}

// --------------------------------------------------------
// screen_show_shot_points - Shows the number of pins knocked down by the player in that shot at the in-game bowling screen
// --------------------------------------------------------
function screen_show_shot_points(){
	
	local screen_player 		= round_player_is_blue ? 1 : 2
	local screen_round			= (round_number + 1)
	local screen_shot			= (shot_number + 1)
	local screen_pos			= "w" + screen_player + "_s" + screen_shot + "_r" + screen_round
	
	log_to_console("mp_coop_bowling.nut -> screen_show_shot_points() -> \"Player: " + screen_player + ", Shot: " + screen_shot + ", Round: " + screen_round + ", Pins: " + shot_pins + "\"")
	
	if(shot_is_strike()){
		EntFire("texture_toggle_" + screen_pos, "SetTextureIndex", 12, 0)
	}
	
	else if(shot_is_spare()){
		EntFire("texture_toggle_" + screen_pos, "SetTextureIndex", 11, 0)
	}
	
	else if(shot_is_miss()){
		EntFire("texture_toggle_" + screen_pos, "SetTextureIndex", 10, 0)
	}
	
	else {
		EntFire("texture_toggle_" + screen_pos, "SetTextureIndex", shot_pins, 0)
	}
	
	EntFire("signage_" + screen_pos, "Enable", "", 2)
}

// --------------------------------------------------------
// screen_show_round_points - Shows the number of points by the player up until now at the in-game bowling screen
// --------------------------------------------------------
function screen_show_round_points(){

	local player_name 		= round_player_is_blue ? "blue" : "orange"
	local player_number 	= round_player_is_blue ? 0 : 1

	log_to_console("mp_coop_bowling.nut -> screen_show_round_points() -> \"Player: " + player_name + ", Special points: " + player_special_types[player_number] + "\"")

	if(player_special_types[player_number] == 0
	|| round_number == 9){
	
		local player_round_draw_points = get_player_points_until_round(round_number)
		
		log_to_console("mp_coop_bowling.nut -> screen_show_round_points() -> \"Round screen number: " + player_round_draw_points + "\"")
	
		for(local x = 0; x < player_round_draw_points.tostring().len(); x++){
			
			local player_points_number = player_round_draw_points.tostring().slice((player_round_draw_points.tostring().len() - (x + 1)), (player_round_draw_points.tostring().len() - x))
			
			EntFire("texture_toggle_w" + (player_number + 1) + "_r" + (round_number + 1) + "_p" + (x + 1), "SetTextureIndex", player_points_number, 0)
			EntFire("points_w" + (player_number + 1) + "_r" + (round_number + 1) + "_p" + (x + 1), "Enable", "", 0)
		}
	}
	
	if(player_draw_on_screen[player_number].len() > 0){

		for(local x = 0; x < player_draw_on_screen[player_number].len(); x++){
		
			local player_round_draw_points = get_player_points_until_round(player_draw_on_screen[player_number][x])
			
			log_to_console("mp_coop_bowling.nut -> screen_show_round_points() -> \"Special Round screen number: " + player_round_draw_points + ", Draw number: " + player_draw_on_screen[player_number][x] + "\"")
			
			for(local y = 0; y < player_round_draw_points.tostring().len(); y++){
				
				local player_points_number = player_round_draw_points.tostring().slice((player_round_draw_points.tostring().len() - (y + 1)), (player_round_draw_points.tostring().len() - y))
			
				EntFire("texture_toggle_w" + (player_number + 1) + "_r" + (player_draw_on_screen[player_number][x] + 1) + "_p" + (y + 1), "SetTextureIndex", player_points_number, 0)
				EntFire("points_w" + (player_number + 1) + "_r" + (player_draw_on_screen[player_number][x] + 1) + "_p" + (y + 1), "Enable", "", 0)
			}
		}
		
		player_draw_on_screen[player_number].clear()
	}
}

// --------------------------------------------------------
// screen_show_previous_game - Shows the previous game on another monitor
// --------------------------------------------------------
function screen_show_previous_game(){

	local player_total_strikes
	local player_total_spares
	local player_total_misses
	local player_total_points
	local player_round_points = [0, 0]
	
	if(game_winner == 0){
		
		player_total_strikes 	= get_player_total_strikes(true)
		player_total_spares		= get_player_total_spares(true)
		player_total_misses		= get_player_total_misses(true)
		player_total_points		= get_player_total_points(true) - get_player_total_points(false)
		
		EntFire("texture_toggle_previous_game_screen", "SetTextureIndex", 6, 0)
	}
	
	else if(game_winner == 1){
		
		player_total_strikes 	= get_player_total_strikes(false)
		player_total_spares		= get_player_total_spares(false)
		player_total_misses		= get_player_total_misses(false)
		player_total_points		= get_player_total_points(false) - get_player_total_points(true)
		
		EntFire("texture_toggle_previous_game_screen", "SetTextureIndex", 7, 0)
	}
	
	else {
		
		player_total_strikes 	= get_player_total_strikes(true) + get_player_total_strikes(false)
		player_total_spares		= get_player_total_spares(true) + get_player_total_spares(false)
		player_total_misses		= get_player_total_misses(true) + get_player_total_misses(false)
		player_total_points		= get_player_total_points(true) + get_player_total_points(false)
	
		EntFire("texture_toggle_previous_game_screen", "SetTextureIndex", 8, 0)
	}
	
	log_to_console("| Blue point table:    " + get_player_total_game_table(true))
	log_to_console("| Orange points table: " + get_player_total_game_table(false))
	log_to_console("|----------------------------------------------------------------------------------")
	log_to_console("| Strikes: " + player_total_strikes)
	log_to_console("| Spares:  " + player_total_spares)
	log_to_console("| Misses:  " + player_total_misses)
	log_to_console("| Points:  " + player_total_points)
	log_to_console("|----------------------------------------------------------------------------------")
	log_to_console("| Previous game screen data...")
	log_to_console("| Bonus shot: " + player_bonus_access[0] + " | " + player_bonus_access[1])
	
	for(local j = 1; j <= 2; j++){
		for(local i = 0; i <= 9; i++){
			
			j == 1
			? player_round_points[(j - 1)] += player_blue_points[i][1]
			: player_round_points[(j - 1)] += player_orange_points[i][1]
			
			local player_boolean 	= j == 1 ? true : false
			local texture_break		= false
			local player_points_len	= player_round_points[(j - 1)].tostring().len()
			local texture_number	= 0
		
			for(local y = 0; y <= 2; y++){
				
				if(i < 9 && y == 2 
				|| i == 9 && y == 2 && player_bonus_access[(j - 1)] == 0){
					continue
				}
				
				if(shot_is_strike(i, y, player_boolean, false)){
					texture_number 	= 12
					
					if(i < 9){
						texture_break = true
					}
				}
				
				else if((i < 9 && y == 1 || i == 9 && y > 0) && shot_is_spare(i, y, player_boolean, false)){
					texture_number 	= 11
					
					if(i < 9){
						texture_break = true
					}
				}
				
				else if(shot_is_miss(i, y, player_boolean, false)){
					texture_number 	= 10
				}
				
				else {
					texture_number 	= player_boolean ? player_blue_points[i][0][y] : player_orange_points[i][0][y]
				}
				
				EntFire("pre_texture_toggle_w" + j + "_s" + (y + 1) + "_r" + (i + 1), "SetTextureIndex", texture_number, 0)
				EntFire("pre_signage_w" + j + "_s" + (y + 1) + "_r" + (i + 1), "Enable", "", 2)
				
				if(texture_break){
					texture_break = false
					break
				}
			}
			
			for(local x = 0; x < player_points_len; x++){
			
				local player_score_number = player_round_points[(j - 1)].tostring().slice((player_round_points[(j - 1)].tostring().len() - (x + 1)), (player_round_points[(j - 1)].tostring().len() - x))
				
				//log_to_console("| ")
				//log_to_console("| Points number length: " + (x + 1) + "/" + player_points_len)
				//log_to_console("| Points number digit:  " + player_score_number)
						
				EntFire("pre_texture_toggle_w" + j + "_r" + (i + 1) + "_p" + (x + 1), "SetTextureIndex", player_score_number, 0)
				EntFire("pre_points_w" + j + "_r" + (i + 1) + "_p" + (x + 1), "Enable", "", 0)
			}
		}
	}
	
	for(local z = 0; z < player_total_strikes.tostring().len(); z++){
		
		local player_strikes_number = player_total_strikes.tostring().slice((player_total_strikes.tostring().len() - (z + 1)), (player_total_strikes.tostring().len() - z))
		
		EntFire("pre_texture_toggle_s" + (z + 1) + "_r1", "SetTextureIndex", player_strikes_number, 0)
		EntFire("pre_won_signage_s" + (z + 1) + "_r1", "Enable", "", 0)
	}
	
	for(local c = 0; c < player_total_spares.tostring().len(); c++){
		
		local player_spares_number 	= player_total_spares.tostring().slice((player_total_spares.tostring().len() - (c + 1)), (player_total_spares.tostring().len() - c))
		
		EntFire("pre_texture_toggle_s" + (c + 1) + "_r2", "SetTextureIndex", player_spares_number, 0)
		EntFire("pre_won_signage_s" + (c + 1) + "_r2", "Enable", "", 0)
	}
	
	for(local v = 0; v < player_total_misses.tostring().len(); v++){
		
		local player_misses_number 	= player_total_misses.tostring().slice((player_total_misses.tostring().len() - (v + 1)), (player_total_misses.tostring().len() - v))
		
		EntFire("pre_texture_toggle_s" + (v + 1) + "_r3", "SetTextureIndex", player_misses_number, 0)
		EntFire("pre_won_signage_s" + (v + 1) + "_r3", "Enable", "", 0)
	}
	
	for(local b = 0; b < player_total_points.tostring().len(); b++){
		
		local player_points_number 	= player_total_points.tostring().slice((player_total_points.tostring().len() - (b + 1)), (player_total_points.tostring().len() - b))
		
		EntFire("pre_texture_toggle_s" + (b + 1) + "_r4", "SetTextureIndex", player_points_number, 0)
		EntFire("pre_won_signage_s" + (b + 1) + "_r4", "Enable", "", 0)
	}
}

// --------------------------------------------------------
// screen_show_game_numbers - Shows the game in numbers, both in total and by both players
// --------------------------------------------------------
function screen_show_game_numbers(type){
	
	local screen_row_numbers 	= []
	local player_number 		= round_player_is_blue ? 0 : 1

	// If the number is shot based
	if(type == "shot"){
		
		if(shot_is_strike()){
			screen_row_numbers.push([[0, 2], (game_strikes[0] + game_strikes[1])])
			screen_row_numbers.push([[(player_number + 1), 2], game_strikes[player_number]])
			log_to_console("mp_coop_bowling.nut -> screen_show_game_numbers() -> \"Type: shot, Shottype: Strike\"")
		}
		
		else if(shot_is_spare()){
			screen_row_numbers.push([[0, 3], (game_spares[0] + game_spares[1])])
			screen_row_numbers.push([[(player_number + 1), 3], game_spares[player_number]])
			log_to_console("mp_coop_bowling.nut -> screen_show_game_numbers() -> \"Type: shot, Shottype: Spare\"")
		}
		
		else if(shot_is_miss()){
			screen_row_numbers.push([[0, 4], (game_misses[0] + game_misses[1])])
			screen_row_numbers.push([[(player_number + 1), 4], game_misses[player_number]])
			log_to_console("mp_coop_bowling.nut -> screen_show_game_numbers() -> \"Type: shot, Shottype: Miss\"")
		}
		
		// All numbers gets added to the screen the following way: screen_row_numbers.push([[section, row], number])
		screen_row_numbers.push([[0, 5], (game_points[0] + game_points[1])])
		screen_row_numbers.push([[(player_number + 1), 5], game_points[player_number]])
	}
	
	// If the number is end game based
	else if(type == "endgame"){
		screen_row_numbers.push([[0, 1], (game_number + 1)])
		
		if(game_winner != 2){
			screen_row_numbers.push([[(game_winner + 1), 1], game_won[game_winner]])
		}
		
		log_to_console("mp_coop_bowling.nut -> screen_show_game_numbers() -> \"Type: endgame, Game: " + (game_number + 1) + ", Winner number: " + game_winner + " \"")
	}
	
	// If the chosen type is undefined
	else {
		return false
	}
	
	// Updates the numbers on the "game in numbers" screen, but only if there are any updates to draw
	if(screen_row_numbers.len() > 0){
	
		// Goes though all the chosen game screen numbers to update
		for(local i = 0; i < screen_row_numbers.len(); i++){
			for(local j = 0; j < screen_row_numbers[i][1].tostring().len(); j++){
				
				local screen_game_number = screen_row_numbers[i][1].tostring().slice((screen_row_numbers[i][1].tostring().len() - (j + 1)), (screen_row_numbers[i][1].tostring().len() - j))
				
				EntFire("number_texture_toggle_w" + screen_row_numbers[i][0][0] + "_s" + (j + 1) + "_r" + screen_row_numbers[i][0][1], "SetTextureIndex", screen_game_number, 0)
				EntFire("number_points_w" + screen_row_numbers[i][0][0] + "_s" + (j + 1) + "_r" + screen_row_numbers[i][0][1], "Enable", "", 0)
			}
		}
	}
}

// --------------------------------------------------------
// get_player_total_strikes - Returns the total number of strikes by a player in the current game
// --------------------------------------------------------
function get_player_total_strikes(player_is_blue){
	
	local total_strikes = 0
	
	for(local i = 0; i <= 9; i++){
		for(local j = 0; j <= 2; j++){
		
			if(i < 9 && j == 2){
				continue
			}
			
			if(shot_is_strike(i, j, player_is_blue, false)){
				total_strikes++
				
				if(i < 9){
					break
				}
			}
		}
	}
	
	return total_strikes
}

// --------------------------------------------------------
// get_player_total_strikes - Returns a hole players table of points
// --------------------------------------------------------
function get_player_total_game_table(player_is_blue){
	
	local game_table 	= "{"
	local player_tp		= [0, 0]
	local player_table	= player_is_blue ? player_blue_points : player_orange_points
	
	for(local i = 0; i <= 9; i++){
	
		game_table += "{{"
		
		for(local j = 0; j <= 2; j++){
			
			if(i < 9 && j == 2){
				continue
			}
			
			else if(i < 9 && j == 1 
			|| i == 9 && j == 2){
				game_table += player_table[i][0][j]
			}
			
			else {
				game_table += player_table[i][0][j] + ","
			}
		}
		
		i < 9 
		? game_table += "}, " + player_table[i][1] + "}, " 
		: game_table += "}, " + player_table[i][1] + "}"
	}
	
	return game_table + "}"
}

// --------------------------------------------------------
// get_player_total_spares - Returns the total number of spares by a player in the current game
// --------------------------------------------------------
function get_player_total_spares(player_is_blue){
	
	local total_spares = 0
	
	for(local i = 0; i <= 9; i++){
		if(shot_is_spare(i, 1, player_is_blue, false) 
		|| i == 9 && shot_is_spare(i, 2, player_is_blue, false) && !shot_is_spare(i, 1, player_is_blue, false)){
			total_spares++
		}
	}
	
	return total_spares
}

// --------------------------------------------------------
// get_player_total_misses - Returns the total number of misses by a player in the current game
// --------------------------------------------------------
function get_player_total_misses(player_is_blue){
	
	local total_misses = 0
	
	for(local i = 0; i <= 9; i++){
		for(local j = 0; j <= 2; j++){
		
			if(i < 9 && j == 2){
				continue
			}
			
			if(shot_is_miss(i, j, player_is_blue, false)){
				total_misses++
			}
		}
	}
	
	return total_misses
}

// --------------------------------------------------------
// get_player_total_points - Returns the total number of points by a player in the current game
// --------------------------------------------------------
function get_player_total_points(player_is_blue){

	local total_points	= 0
	local player_points	= player_is_blue ? player_blue_points : player_orange_points
	
	foreach(index, rounds in player_points){
		total_points += player_points[index][1]
	}
	
	return total_points
}

// --------------------------------------------------------
// get_player_points_until_round - Returns all of a given players points up to and with a defined round
// --------------------------------------------------------
function get_player_points_until_round(round){

	local total_points	= 0
	local player_points	= round_player_is_blue ? player_blue_points : player_orange_points
	
	for(local i = 0; i <= round; i++){
		total_points += player_points[i][1]
	}
	
	return total_points
}

// --------------------------------------------------------
// add_shot_points - Gives shot points in the current shot and round by the player and shows the current overthown turrets if needed
// --------------------------------------------------------
function add_shot_points(points){
	
	shot_points[shot_number] += points
	shot_pins++
}

// --------------------------------------------------------
// add_round_points - Gives the current player all the points in the current round by him
// --------------------------------------------------------
function add_round_points(){
	
	local points = shot_points[0] + shot_points[1] + shot_points[2]
	
	if(round_player_is_blue){
		player_blue_points[round_number][1] += points
	}
	
	else {
		player_orange_points[round_number][1] += points
	}
}

// --------------------------------------------------------
// check_shot_type - Checks what kind of shot the player got and what to do in one of the given situations
// --------------------------------------------------------
function check_shot_type(){

	local player_number = round_player_is_blue ? 0 : 1
	
	if(shot_is_strike()){
		game_strikes[player_number] 	 	+= 1
		player_special_types[player_number]	+= 1
	}
	
	else if(shot_is_spare()){
		game_spares[player_number] 		 	+= 1
		player_special_types[player_number]	+= 1
	}
	
	else if(shot_is_miss()){
		game_misses[player_number] 		 += 1
	}
	
	game_points[player_number] += shot_points[shot_number]
}

// --------------------------------------------------------
// check_shot_pins - Checks the current playing player and adds the number of knocked down pins in that round
// --------------------------------------------------------
function check_shot_pins(){
	
	log_to_console("mp_coop_bowling.nut -> check_shot_pins() -> \"Pins: " + shot_pins + "/10\"")
	
	if(round_player_is_blue){
		player_blue_points[round_number][0][shot_number] += shot_pins
	}
	
	else {
		player_orange_points[round_number][0][shot_number] += shot_pins
	}
	
	shot_pins = 0
}

// --------------------------------------------------------
// check_bonus_points - Gives the current player bonus points for strikes and spares
// --------------------------------------------------------
function check_bonus_points(){

	local player_name 		= round_player_is_blue ? "blue" : "orange"
	local player_number 	= round_player_is_blue ? 0 : 1
	
	// If the current player got two strikes in a row and either points, miss or another strike third time - [Strike, Strike, (Miss, Points or Strike)]
	if(round_number > 1 && shot_number == 0
	&& shot_is_strike((round_number - 2), 0, round_player_is_blue, false) && shot_is_strike((round_number - 1), 0, round_player_is_blue, false)){
	
		log_to_console("| mp_coop_bowling.nut -> check_bonus_points() -> \"Player: " + player_name + ", Round: " + (round_number + 1) + ", Shot: 0, Type: strike, Addition: " + (round_player_is_blue ? player_blue_points[(round_number - 1)][0][0] + shot_points[0] : player_orange_points[(round_number - 1)][0][0] + shot_points[0]) + "\"")
		
		if(round_player_is_blue){
			game_points[0] 								+= player_blue_points[(round_number - 1)][0][0] + shot_points[0]
			player_blue_points[(round_number - 2)][1] 	+= player_blue_points[(round_number - 1)][0][0] + shot_points[0]
		}
		
		else {
			game_points[1] 								+= player_orange_points[(round_number - 1)][0][0] + shot_points[0]
			player_orange_points[(round_number - 2)][1] += player_orange_points[(round_number - 1)][0][0] + shot_points[0]
		}
		
		player_draw_on_screen[player_number].push((round_number - 2))
		player_special_types[player_number] -= 1
	}
	
	// If the current player got a strike last round and either a spare or an open round this time - [Strike, (Misses, Spare or Points)]
	else if(round_number > 0 && shot_number == 1 && shot_is_strike((round_number - 1), 0, round_player_is_blue, false)){
		
		log_to_console("mp_coop_bowling.nut -> check_bonus_points() -> \"Player: " + player_name + ", Round: " + (round_number + 1)  + ", Shot: 0, Type: strike, Addition: " + (shot_points[0] + shot_points[1]) + "\"")
		
		if(round_player_is_blue){
			game_points[0] 								+= shot_points[0] + shot_points[1]
			player_blue_points[(round_number - 1)][1]	+= shot_points[0] + shot_points[1]
		}
		
		else {
			game_points[1] 								+= shot_points[0] + shot_points[1]
			player_orange_points[(round_number - 1)][1]	+= shot_points[0] + shot_points[1]
		}
		
		player_draw_on_screen[player_number].push((round_number - 1))
		player_special_types[player_number] -= 1
	}
	
	// If the current player got a spare last round
	if(round_number > 0 && shot_number == 0 && shot_is_spare((round_number - 1), 1, round_player_is_blue, false)){
	
		log_to_console("mp_coop_bowling.nut -> check_bonus_points() -> \"Player: " + player_name + ", Round: " + (round_number + 1) + ", Shot: 1, Type: spare, Addition: " + (shot_points[0]) + "\"")
		
		if(round_player_is_blue){
			game_points[0] 								+= shot_points[0]
			player_blue_points[(round_number - 1)][1] 	+= shot_points[0]
		}
		
		else {
			game_points[1] 								+= shot_points[0]
			player_orange_points[(round_number - 1)][1]	+= shot_points[0]
		}
		
		player_draw_on_screen[player_number].push((round_number - 1))
		player_special_types[player_number] -= 1
	}
	
	// If there shall be given bonus points in the last round
	if(round_number == 9){
		
		// If the current player got a strike in the first shot and is in the bonus shot now
		if(shot_number == 2 && shot_is_strike(round_number, 0, round_player_is_blue, false)){
		
			log_to_console("mp_coop_bowling.nut -> check_bonus_points() -> \"Player: " + player_name + ", Round: " + (round_number + 1)  + ", Shot: 0, Type: strike, Addition: " + (shot_points[1] + shot_points[2]) + "\"")
			
			if(round_player_is_blue){
				game_points[0] 							+= shot_points[1] + shot_points[2]
				player_blue_points[round_number][1]		+= shot_points[1] + shot_points[2]
			}
			
			else {
				game_points[1] 							+= shot_points[1] + shot_points[2]
				player_orange_points[round_number][1]	+= shot_points[1] + shot_points[2]
			}
			
			player_special_types[player_number] -= 1
		}
		
		// If the current layer got a spare in the first two shots and is in the bonus shot now
		else if(shot_number == 2 && shot_is_spare(round_number, 1, round_player_is_blue, false) && (shot_is_points() || shot_is_strike() || shot_is_miss())){
			
			log_to_console("mp_coop_bowling.nut -> check_bonus_points() -> \"Player: " + player_name + ", Round: " + (round_number + 1) + ", Shot: 1, Type: spare, Addition: " + (shot_points[2]) + "\"")
			
			if(round_player_is_blue){
				game_points[0] 							+= shot_points[2]
				player_blue_points[round_number][1]		+= shot_points[2]
			}
			
			else {
				game_points[1] 							+= shot_points[2]
				player_orange_points[round_number][1]	+= shot_points[2]
			}
			
			player_special_types[player_number] -= 1
		}
	}
}

// --------------------------------------------------------
// check_for_achievements - Gives the current player an achievement if all criteria is met
// --------------------------------------------------------
function check_for_achievements(type){

	local player_name 		= round_player_is_blue ? "blue" : "orange"
	local player_number 	= round_player_is_blue ? 0 : 1
	
	// If the achievement is shot based
	if(type == "shot"){
	
		// Counts the current players in-game spares in a row
		if(shot_number == 1 && shot_is_spare()){
			av_spares_in_a_row[player_number] += 1
			av_spares_in_a_game[player_number] += 1
		}
		
		// Resets the current players "spares in a row" if it is anything than a spare
		else if(shot_number == 1 && !shot_is_spare() || shot_is_strike()) {
			av_spares_in_a_row[player_number] = 0
		}
		
		// Counts the current players in-game strikes in a row
		if(shot_is_strike()){
			av_strikes_in_a_row[player_number] += 1
			av_strikes_in_a_game[player_number] += 1
		}
		
		// Resets the current players "strikes in a row" if it is anything than a strike
		else {
			av_strikes_in_a_row[player_number] = 0
		}
		
		// If the player: knocks down a pin
		if(shot_pins > 0 && achievement_knock_down_a_pin[player_number] == 0){
			achievement_knock_down_a_pin[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_knock_down_a_pin\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s5_r1", "SetTextureIndex", "1", 0)
		}
		
		// If the player: knocks down multiple pins in a shot
		if(shot_pins > 1 && achievement_knock_down_multiple_pins[player_number] == 0){
			achievement_knock_down_multiple_pins[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_knock_down_multiple_pins\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s6_r1", "SetTextureIndex", "1", 0)
		}
		
		// If the player: misses any pins in a shot
		if(shot_pins == 0 && achievement_miss_any_pins_in_a_shot[player_number] == 0){
			achievement_miss_any_pins_in_a_shot[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_miss_any_pins_in_a_shot\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s1_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: misses all pins in a frame
		if(shot_number == 1 && (shot_points[0] + shot_points[1]) == 0 && achievement_miss_a_frame[player_number] == 0){
			achievement_miss_a_frame[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_miss_a_frame\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s2_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: do not knock down all the pins in a frame (open frame)
		if(shot_number == 1 && (shot_points[0] + shot_points[1]) < 10 && achievement_make_an_open_frame[player_number] == 0){
			achievement_make_an_open_frame[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_make_an_open_frame\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s3_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets a spare
		if(shot_is_spare() && achievement_get_a_spare[player_number] == 0){
			achievement_get_a_spare[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_a_spare\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s4_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets two spares in a row
		if(av_spares_in_a_row[player_number] == 2 && achievement_get_two_spares_in_a_row[player_number] == 0){
			achievement_get_two_spares_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_two_spares_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s5_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets four spares in a row
		if(av_spares_in_a_row[player_number] == 4 && achievement_get_four_spares_in_a_row[player_number] == 0){
			achievement_get_four_spares_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_four_spares_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s6_r2", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets a strike
		if(shot_is_strike() && achievement_get_a_strike[player_number] == 0){
			achievement_get_a_strike[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_a_strike\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s2_r3", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets two strikes in a row
		if(av_strikes_in_a_row[player_number] == 2 && achievement_get_two_strikes_in_a_row[player_number] == 0){
			achievement_get_two_strikes_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_two_strikes_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s3_r3", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets four strikes in a row
		if(av_strikes_in_a_row[player_number] == 4 && achievement_get_four_strikes_in_a_row[player_number] == 0){
			achievement_get_four_strikes_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_four_strikes_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s4_r3", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets six strikes in a row
		if(av_strikes_in_a_row[player_number] == 6 && achievement_get_six_strikes_in_a_row[player_number] == 0){
			achievement_get_six_strikes_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_six_strikes_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s5_r3", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets eight strikes in a row
		if(av_strikes_in_a_row[player_number] == 8 && achievement_get_eight_strikes_in_a_row[player_number] == 0){
			achievement_get_eight_strikes_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_eight_strikes_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s6_r3", "SetTextureIndex", "1", 0)
		}
		
		// If the player: gets ten strikes in a row
		if(av_strikes_in_a_row[player_number] == 10 && achievement_get_ten_strikes_in_a_row[player_number] == 0){
			achievement_get_ten_strikes_in_a_row[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_get_ten_strikes_in_a_row\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s1_r4", "SetTextureIndex", "1", 0)
		}
	}
	
	// If the achievement is end game based (still based on the shots)
	else if(type == "endgame"){
	
		local player_blue_total_points	 	= get_player_total_points(true)
		local player_orange_total_points 	= get_player_total_points(false)
		
		// If blue won the current game
		if(player_blue_total_points > player_orange_total_points){
			av_games_won_in_a_row[0] += 1
			av_games_won_in_a_row[1] = 0
			
			// If blue: won a game
			if(achievement_win_a_game[0] == 0){
				achievement_win_a_game[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_win_a_game\"")
				EntFire("achievement_toggle_w1_s1_r1", "SetTextureIndex", "1", 0)
			}
			
			// If blue: won two games in a row
			if(av_games_won_in_a_row[0] == 2 && achievement_win_two_games_in_a_row[0] == 0){
				achievement_win_two_games_in_a_row[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_win_two_games_in_a_row\"")
				EntFire("achievement_toggle_w1_s2_r1", "SetTextureIndex", "1", 0)
			}
			
			// If blue: won a game without any spares
			if(av_spares_in_a_game[0] == 0 && achievement_win_a_game_without_spares[0] == 0){
				achievement_win_a_game_without_spares[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_win_a_game_without_spares\"")
				EntFire("achievement_toggle_w1_s1_r3", "SetTextureIndex", "1", 0)
			}
			
			// If blue: won a game without any strikes
			if(av_strikes_in_a_game[0] == 0 && achievement_win_a_game_without_strikes[0] == 0){
				achievement_win_a_game_without_strikes[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_win_a_game_without_strikes\"")
				EntFire("achievement_toggle_w1_s3_r4", "SetTextureIndex", "1", 0)
			}
			
			// If blue: makes a perfect game (12 strikes in a row)
			if(av_strikes_in_a_row[0] == 12 && achievement_make_a_perfect_game[0] == 0){
				achievement_make_a_perfect_game[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_make_a_perfect_game\"")
				EntFire("achievement_toggle_w1_s2_r4", "SetTextureIndex", "1", 0)
			}
			
			// If orange: loses a game
			if(achievement_lose_a_game[1] == 0){
				achievement_lose_a_game[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_lose_a_game\"")
				EntFire("achievement_toggle_w2_s3_r1", "SetTextureIndex", "1", 0)
			}
			
			// If orange: loses two games in a row
			if(av_games_won_in_a_row[0] == 2 && achievement_lose_two_games_in_a_row[1] == 0){
				achievement_lose_two_games_in_a_row[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_lose_two_games_in_a_row\"")
				EntFire("achievement_toggle_w2_s4_r1", "SetTextureIndex", "1", 0)
			}
		}
		
		// If orange won the current game
		else if(player_blue_total_points < player_orange_total_points){
			av_games_won_in_a_row[1] += 1
			av_games_won_in_a_row[0] = 0
			
			// If orange: won a game
			if(achievement_win_a_game[1] == 0){
				achievement_win_a_game[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_win_a_game\"")
				EntFire("achievement_toggle_w2_s1_r1", "SetTextureIndex", "1", 0)
			}
			
			// If orange: won two games in a row
			if(av_games_won_in_a_row[1] == 2 && achievement_win_two_games_in_a_row[1] == 0){
				achievement_win_two_games_in_a_row[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_win_two_games_in_a_row\"")
				EntFire("achievement_toggle_w2_s2_r1", "SetTextureIndex", "1", 0)
			}
			
			// If orange: won a game without any spares
			if(av_spares_in_a_game[1] == 0 && achievement_win_a_game_without_spares[1] == 0){
				achievement_win_a_game_without_spares[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_win_a_game_without_spares\"")
				EntFire("achievement_toggle_w2_s1_r3", "SetTextureIndex", "1", 0)
			}
			
			// If orange: won a game without any strikes
			if(av_strikes_in_a_game[1] == 0 && achievement_win_a_game_without_strikes[1] == 0){
				achievement_win_a_game_without_strikes[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_win_a_game_without_strikes\"")
				EntFire("achievement_toggle_w2_s3_r4", "SetTextureIndex", "1", 0)
			}
			
			// If orange: makes a perfect game (12 strikes in a row)
			if(av_strikes_in_a_row[1] == 12 && achievement_make_a_perfect_game[1] == 0){
				achievement_make_a_perfect_game[1] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"orange got achievement: achievement_make_a_perfect_game\"")
				EntFire("achievement_toggle_w2_s2_r4", "SetTextureIndex", "1", 0)
			}
			
			// If blue: loses a game
			if(achievement_lose_a_game[0] == 0){
				achievement_lose_a_game[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_lose_a_game\"")
				EntFire("achievement_toggle_w1_s3_r1", "SetTextureIndex", "1", 0)
			}
			
			// If blue: loses two games in a row
			if(av_games_won_in_a_row[1] == 2 && achievement_lose_two_games_in_a_row[0] == 0){
				achievement_lose_two_games_in_a_row[0] = 1
				
				log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"blue got achievement: achievement_lose_two_games_in_a_row\"")
				EntFire("achievement_toggle_w1_s4_r1", "SetTextureIndex", "1", 0)
			}
		}
	}
	
	// If the achievement is a secret based
	else if(type == "secret"){
		
		// If the player: uses the secret in a game
		if(achievement_use_the_secret_in_a_game[player_number] == 0){
			achievement_use_the_secret_in_a_game[player_number] = 1
			
			log_to_console("mp_coop_bowling.nut -> check_for_achievements() -> \"" + player_name + " got achievement: achievement_use_the_secret_in_a_game\"")
			EntFire("achievement_toggle_w" + (player_number + 1) + "_s4_r4", "SetTextureIndex", "1", 0)
		}
	}
	
	// If the chosen type is undefined
	else {
		return false
	}
}

// --------------------------------------------------------
// lock_game - Locks the game, so players are unable to start a new game before the current one is finishes
// --------------------------------------------------------
function lock_game(){
	if(!game_locked){
		log_to_console("\n Game Locked! \n")
		game_locked = true
	}
}

// --------------------------------------------------------
// total_reset_game - Resets the game totally, if the game is not locked
// --------------------------------------------------------
function total_reset_game(){
	if(!game_locked){
		log_to_console("\n Game Total Resetted! \n")
		reset_total()
	}
}

// --------------------------------------------------------
// autostart_game - Automatically starts a new game, when the current one is finished
// --------------------------------------------------------
function autostart_game(){
	log_to_console("\n Game Autostart! \n")
	game_autonew = !game_autonew
}

// --------------------------------------------------------
// shot_is_secret - The player uses the secret to score
// --------------------------------------------------------
function shot_is_secret(){
	EntFire("@turret_secret_relay", "Trigger", "", 0)
	check_for_achievements("secret")
}

// --------------------------------------------------------
// shot_is_strike - Checks if a given shot is a strike
// --------------------------------------------------------
function shot_is_strike(round = round_number, shot = shot_number, player = round_player_is_blue, current_round = true){
	
	if(current_round){
	
		if(round_number < 9 && shot_number == 0 && shot_points[shot_number] == 10
		|| round_number == 9 && shot_points[shot_number] == 10){
			return true
		}
		
		else {
			return false
		}
	}
	
	else {
		if(player){
			if(round < 9 && shot == 0 && player_blue_points[round][0][shot] == 10
			|| round == 9 && player_blue_points[round][0][shot] == 10){
				return true
			}
			
			else {
				return false
			}
		}
		
		else {
			if(round < 9 && shot == 0 && player_orange_points[round][0][shot] == 10 
			|| round == 9 && player_orange_points[round][0][shot] == 10){
				return true
			}
			
			else {
				return false
			}
		}
	}
}

// --------------------------------------------------------
// shot_is_spare - Checks if a given shot is a spare
// --------------------------------------------------------
function shot_is_spare(round = round_number, shot = shot_number, player = round_player_is_blue, current_round = true){
	
	if(current_round){
	
		if(shot_number == 1 && (shot_points[0] + shot_points[1]) == 10 && shot_points[1] > 0
		|| round_number == 9 && shot_number == 2 && (shot_points[1] + shot_points[2]) == 10 && (shot_points[0] != shot_points[2] || shot_points[0] == 10) && (shot_points[0] + shot_is_points[1]) != 10){
			return true
		}
		
		else {
			return false
		}
	}
	
	else {
		if(player){
			if(shot == 1 && (player_blue_points[round][0][0] + player_blue_points[round][0][1]) == 10 && player_blue_points[round][0][1] > 0
			|| round == 9 && shot == 2 && (player_blue_points[round][0][1] + player_blue_points[round][0][2]) == 10 && (player_blue_points[round][0][0] != player_blue_points[round][0][2] 
			|| player_blue_points[round][0][0] == 10) && (player_blue_points[round][0][0] + player_blue_points[round][0][1]) != 10){
				return true
			}
			
			else {
				return false
			}
		}
		
		else {
			if(shot == 1 && (player_orange_points[round][0][0] + player_orange_points[round][0][1]) == 10 && player_orange_points[round][0][1] > 0
			|| round == 9 && shot == 2 && (player_orange_points[round][0][1] + player_orange_points[round][0][2]) == 10 && (player_orange_points[round][0][0] != player_orange_points[round][0][2] 
			|| player_orange_points[round][0][0] == 10) && (player_orange_points[round][0][0] + player_orange_points[round][0][1]) != 10){
				return true
			}
			
			else {
				return false
			}
		}
	}
}

// --------------------------------------------------------
// shot_is_miss - Checks if a given shot is a miss
// --------------------------------------------------------
function shot_is_miss(round = round_number, shot = shot_number, player = round_player_is_blue, current_round = true){
	
	if(current_round){
	
		if(shot_points[shot_number] == 0 && !shot_is_spare(round, shot_number, player, current_round) && !shot_is_strike(round, shot_number, player, current_round)){
			return true
		}
		
		else {
			return false
		}
	}
	
	else {
		local player_number = player ? 0 : 1
		
		if(player == true){
			if(player_blue_points[round][0][shot] == 0  && !shot_is_spare(round, shot, player, current_round) && (round < 9 && !shot_is_strike(round, 0, player, current_round) || round == 9 && !shot_is_strike(round, shot, player, current_round) && (shot < 2 || shot == 2 && player_bonus_access[player_number] == 1))){
				return true
			}
			
			else {
				return false
			}
		}
		
		else {
			if(player_orange_points[round][0][shot] == 0  && !shot_is_spare(round, shot, player, current_round) && (round < 9 && !shot_is_strike(round, 0, player, current_round) || round == 9 && !shot_is_strike(round, shot, player, current_round) && (shot < 2 || shot == 2 && player_bonus_access[player_number] == 1))){
				return true
			}
			
			else {
				return false
			}
		}
	}
}

// --------------------------------------------------------
// shot_is_points - Checks if a given shot is not one of a special kind
// --------------------------------------------------------
function shot_is_points(round = round_number, shot = shot_number, player = round_player_is_blue, current_round = true){
	
	if(current_round){
	
		if(shot_number == 0 && shot_points[0] > 0 && shot_points[0] < 10
		|| shot_number == 1 && shot_points[1] > 0 && shot_points[1] < 10 && (shot_points[0] + shot_points[1]) < 10 
		|| shot_number == 2 && shot_points[2] > 0 && ((shot_points[1] + shot_points[2]) < 10 && shot_points[0] == 10 || (shot_points[0] + shot_points[1]) == 10 && shot_points[2] < 10 || shot_points[0] == 10 && shot_points[1] == 10 && shot_points[2] < 10)){
			return true
		}
		
		else {
			return false
		}
	}
	
	else {
		if(player){
			if(shot == 0 && player_blue_points[round][0][shot] > 0 && player_blue_points[round][0][shot] < 10
			|| shot == 1 && player_blue_points[round][0][shot] > 0 && player_blue_points[round][0][shot] < 10 && (player_blue_points[round][0][0] + player_blue_points[round][0][shot]) < 10 
			|| shot == 2 && player_blue_points[round][0][shot] > 0 && ((player_blue_points[round][0][1] + player_blue_points[round][0][shot]) < 10 && player_blue_points[round][0][0] == 10 || (player_blue_points[round][0][0] + player_blue_points[round][0][1]) == 10 && player_blue_points[round][0][shot] < 10 || player_blue_points[round][0][0] == 10 && player_blue_points[round][0][1] == 10 && player_blue_points[round][0][shot] < 10)){
				return true
			}
			
			else {
				return false
			}
		}
		
		else {
			if(shot == 0 && player_orange_points[round][0][shot] > 0 && player_orange_points[round][0][shot] < 10
			|| shot == 1 && player_orange_points[round][0][shot] > 0 && player_orange_points[round][0][shot] < 10 && (player_orange_points[round][0][0] + player_orange_points[round][0][shot]) < 10 
			|| shot == 2 && player_orange_points[round][0][shot] > 0 && ((player_orange_points[round][0][1] + player_orange_points[round][0][shot]) < 10 && player_orange_points[round][0][0] == 10 || (player_orange_points[round][0][0] + player_orange_points[round][0][1]) == 10 && player_orange_points[round][0][shot] < 10 || player_orange_points[round][0][0] == 10 && player_orange_points[round][0][1] == 10 && player_orange_points[round][0][shot] < 10)){
				return true
			}
			
			else {
				return false
			}
		}
	}
}