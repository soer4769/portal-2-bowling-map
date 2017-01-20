// Global variables
debug	<- false

// Map order
MapPlayOrder <- [
	"mp_coop_bowling"
]

// --------------------------------------------------------
// LogToConsole - Prints a message to the console if debugging is on
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

// Changes to the next map
function TransitionFromMap(){
	
	// Local variables
	local nextmap = -2
 
	// Loop through maps
	foreach(index, map in MapPlayOrder){
		
		// This is the map we're on
		if(GetMapName() == MapPlayOrder[index]){
			nextmap = -1
		}
		
		// This is not the map we are on
		else {
			
			// This is the first map past the map we are on
			if(nextmap == -1){
				nextmap = index
			}
		}
	}
	
	// We found a map; go to it
	if (nextmap > 0){
		LogToConsole("mp_coop_transition_simple.nut -> TransitionFromMap() -> \"Teleporting to the next map: " + MapPlayOrder[nextmap] + "\"")
		EntFire("@servercommand", "command", "changelevel " + MapPlayOrder[nextmap], 1.0)
	}
	
	// No map found; we're done
	else {
		// Triggers the vote page (before the final level ends)
		EntFire("@relay_pti_level_end","Trigger","", 0.0)
		
		LogToConsole("mp_coop_transition_simple.nut -> TransitionFromMap() -> \"No next map found: disconnected\"")
		EntFire("@servercommand", "command", "disconnect", 2.0)
	}
}

// --------------------------------------------------------
// DumpMapList - Dumps all the playorder maps to the console
// --------------------------------------------------------
function DumpMapList(){
	
	// If there is chosen to be able to debug the maps
	if(debug){
		
		// Local variables
		local mapcount = 0
		
		// Print to the console
		LogToConsole("sp_instance_list.nut -> DumpMapList() -> \"Debug: " + debug + "\"")
		LogToConsole("----------------------------------------")
		
		// Loops though each map
		foreach(index, map in MapPlayOrder){
				
			// If this is the current map
			if(GetMapName() == MapPlayOrder[index]){
				LogToConsole(mapcount + ": " + MapPlayOrder[index] + " <- You are here")
			}
			
			// If this is another map
			else {
				LogToConsole(mapcount + ": " + MapPlayOrder[index])
			}
			
			// Increases the total map count
			mapcount++
		}
		
		// Prints to the console
		LogToConsole("----------------------------------------")
		LogToConsole("Total map count: " + mapcount)
		LogToConsole("---------------------------------------- \n")
	}
}

// Teleports playeres to there right position before transition
function PrepareTeleport(){
	LogToConsole("mp_coop_transition_simple.nut -> OnPostTransition() -> \"Teleporting players to end rooms\"" )
	EntFire("@teleport_trigger", "Enable", 0, 0)
}