// Global variables
debug								<- false
portal_door_array 					<- []
portal_door_linked_target_array 	<- []
number_of_doors 					<- 0
player_door_distance 				<- 80

// --------------------------------------------------------
// LogToConsole - Prints a message to the console
// --------------------------------------------------------
function LogToConsole(arg){
	
	// If debug is true
	if(debug){
		printl(arg)
	}
	
	// If debug is false
	else {
		return false
	}
}

//---------------------------------------------------------
// CollectDoors - Collect Doors in map into arrays and remove reciprocal entries
//---------------------------------------------------------
function CollectDoors(){
	
	// Local variables
	local cur_ent = null
	
	// Clear the arrays
	portal_door_array.clear()
	portal_door_linked_target_array.clear()

	// Reset door count
	number_of_doors = 0
	
	// Collect doors into array
	do {
		
		// Finds all prop_linked_portal_door entities in the map
		local reciprocal 	= false
		cur_ent 			= Entities.FindByClassname(cur_ent, "prop_linked_portal_door")
		
		// If any door entities are found
		if(cur_ent != null){
			
			// Loops though all doors found in the map
			foreach(index, door in portal_door_linked_target_array){
				
				// If the given door target is found
				if(portal_door_linked_target_array[index]){
					
					// If the current doors are partners
					if(cur_ent.GetName() == portal_door_linked_target_array[index].GetName()){
						
						// If the current doors are partners
						if(portal_door_linked_target_array[index].GetPartnerInstance().GetName() == portal_door_array[index].GetName()){
							reciprocal = true
						}
					}
				}
			}
			
			// If we have not yet found any doors
			if(!reciprocal){
				
				// Separates the current door and its partner into two different arrays
				portal_door_array.append(cur_ent)
				portal_door_linked_target_array.append(portal_door_array[number_of_doors].GetPartnerInstance())			
				number_of_doors++
			}
		}
		
	} while(cur_ent != null)
	
	// Logs the data to the console
	DebugDumpDoorArrayData()
}

//---------------------------------------------------------
// DebugDumpDoorArrayData - Prints all door entities found to the console
//---------------------------------------------------------
function DebugDumpDoorArrayData(){
	
	// Logs the number of doors found
	LogToConsole("noclip_door_open_sensor.nut -> DebugDumpDoorArrayData() -> \"Debug: " + debug + "\"")
	LogToConsole("----------------------------------------")
	
	// Loops though all the doors
	foreach(index, door in portal_door_linked_target_array){
		
		// Logs the door if it is found
		if(portal_door_linked_target_array[index]){
			LogToConsole(index + ": " + portal_door_array[index].GetName() + " <> " + portal_door_linked_target_array[index].GetName())
		}
	}
	
	// Ends the section
	LogToConsole("----------------------------------------")
	LogToConsole("Total door count: " + number_of_doors)
	LogToConsole("---------------------------------------- \n")
}

//---------------------------------------------------------
// DrawLinkedPartnerLines - Draws lines between linked doors if we are in debug mode
//---------------------------------------------------------
function DrawLinkedPartnerLines(){
	
	// Loops though all doors
	for(local i = 0; i < portal_door_linked_target_array.len(); i++){
		
		// Draw a debug line, if the given door is found
		if(portal_door_linked_target_array[i]){
			DebugDrawLine(portal_door_array[i].GetOrigin(), portal_door_linked_target_array[i].GetOrigin(), 100, 100, 100, true, 0.2)
		}
	}
}

//---------------------------------------------------------
// Think - Opens linked doors if the player is noclipping in singleplayer within the given distance of a door pair
//---------------------------------------------------------
function Think(){

	// If the player is noclipping in singleplayer
	if(IsMultiplayer() == false && player.IsNoclipping()){
		
		// Collects all the doors
		CollectDoors()
		
		// Draws lines bewteen doors, if we are in debug mode
		if(debug){
			DrawLinkedPartnerLines()
		}
		
		// Local variables
		local cur_ent 				= null
		local linked_partner_name 	= null
		
		// Finds all doors within the players given distance and opens them if necessary
		do {
			
			// Finds the nearst door to the player
			cur_ent = Entities.FindByClassnameWithin(cur_ent, "prop_linked_portal_door", player.GetOrigin(), player_door_distance)
			
			// If any doors are found
			if(cur_ent){
				EntFire(cur_ent.GetName(), "open")
			}
			
		} while (cur_ent != null)
	}
}