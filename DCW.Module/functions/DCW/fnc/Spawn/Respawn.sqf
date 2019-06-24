/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */

params ["_player"];

if (!RESPAWN_ENABLED)then {
	NUMBER_RESPAWN = 0;
	REMAINING_RESPAWN = 0;
};

[] spawn fnc_surrenderSystem;

RESPAWN_CHOICE = "";
REMAINING_RESPAWN = NUMBER_RESPAWN;

fnc_HandleRespawnBase = {
	params["_unit"];
	// Remove units around the player
	{ if (_unit distance _x < 100 && side _x == SIDE_ENEMY) then {_x setDamage 1;} } foreach allUnits;

	PLAYER_ALIVE = true;

	// Create a basic hidden marker on player's position (Used for blacklisting purposes)
	_pm = createMarker [format["player-marker-%1",name _unit], getPos _unit];
	_pm setMarkerShape "ELLIPSE";
	_pm setMarkerColor "ColorGreen";
	_pm setMarkerAlpha 0;
	_pm setMarkerSize [200,200];
	if (DEBUG) then {
		_pm setMarkerAlpha .3;
	};
	_unit setVariable["marker", _pm, true];

	//Default trait
	_unit setUnitTrait ["explosiveSpecialist",true];

	// Corrected player rating
	 if (rating _unit < 0) then {
		_unit addRating ((-(rating _unit)) + 1000);
	};

	//Squad leader specific
	sleep 2;


	if ((leader GROUP_PLAYERS) == _unit) then {
		RemoveAllActions _unit;
		_unit call fnc_ActionCamp;
		_unit call fnc_supportuiInit;
	};

	// Initial score display
	[] call fnc_displayscore;

};

//Respawn handling
// Singleplayer
fnc_HandleRespawnSingleplayer =
{
	params["_unit"];

	_loadout = getUnitLoadout _unit;
	
	waitUntil{!PLAYER_ALIVE};
	_unit allowDamage false;
	 
	 
	// Create a basic hidden marker on player's position (Used for blacklisting purposes)
	/*deletemarker MARKER
	_pm = createMarker [format["player-marker-%1",random 1000], getPos _unit];
	_pm setMarkerShape "ELLIPSE";
	_pm setMarkerColor "ColorGreen";
	_pm setMarkerAlpha 0;
	_pm setMarkerSize [200,200];
	if (DEBUG) then {
		_pm setMArkerAlpha .3;
	};*/
	//_unit setVariable["marker", _pm, true];

	// Initial score display
	[] call fnc_displayscore;
	

	//count the remaining lives after death
	REMAINING_RESPAWN = REMAINING_RESPAWN - 1;
	if (REMAINING_RESPAWN == -1) exitWith{ endMission "LOSER"; };
	
	cutText ["Respawning...","BLACK OUT", 7];
	sleep 7;
	_unit setUnconscious false;
	_unit setDamage 0;
	
	_timeSkipped = round(6 + random 12);
	cutText ["Respawning...","BLACK FADED", 999];
	sleep 2;
	cutText ["","BLACK FADED",  999];
	[] call fnc_respawndialog;
	waitUntil{ RESPAWN_CHOICE != "" };
	cutText [format["Back to %1...", RESPAWN_CHOICE], "BLACK FADED", 999];
	sleep 1;
	
	// Move the alive AI unit back to position
	private _respawnPos = if (RESPAWN_CHOICE == "base") then {START_POSITION} else {CAMP_RESPAWN_POSITION};
	RESPAWN_CHOICE = ""; // Reset
	

	if (!isMultiplayer) then {
		{ 
			if(!isPlayer _x && (leader GROUP_PLAYERS) == _unit) then{
				_x setPos ([_respawnPos, 0 ,10, 1, 0, 20, 0] call BIS_fnc_findSafePos);
				_x getVariable["DCW_marker_injured",""] setMarkerPos (getPos _x);
				if (ACE_ENABLED) then {
					[objNull, _x] call ace_medical_fnc_treatmentAdvanced_fullHealLocal;
				};
			}; 
		}foreach  units (group _unit);
	};

	sleep 1;


	//Disable chasing if not in multiplayer
	if (!isMultiplayer) then{
		CHASER_TRIGGERED = false;
		publicVariable "CHASER_TRIGGERED";
	}; 

    resetCamShake;
	_unit setPos _respawnPos;
	[player] call fnc_HandleRespawnBase;


	if (ACE_ENABLED) then {
		[objNull, player] call ace_medical_fnc_treatmentAdvanced_fullHealLocal;
	};

	_unit setCaptive true;
	_unit setUnitLoadout _loadout;

	_unit switchMove "Acts_welcomeOnHUB01_PlayerWalk_6";

	//Black screen with timer...
	sleep 2;
	cutText ["","BLACK FADED", 999];
	
	BIS_DeathBlur ppEffectAdjust [0.0];
	BIS_DeathBlur ppEffectCommit 0;

	cutText ["","BLACK FADED", 999];
	
    if (!isMultiplayer) then {
		skipTime 6 + random 12;
	};
	
	sleep 5;
	[worldName, "Back to camp",format["%1 hours later...",_timeSkipped], format ["%1 live%2 left",REMAINING_RESPAWN,if (REMAINING_RESPAWN <= 1) then {""}else{"s"}]] call BIS_fnc_infoText;
	cutText ["","BLACK IN", 4];
	"dynamicBlur" ppEffectEnable true;   
	"dynamicBlur" ppEffectAdjust [6];   
	"dynamicBlur" ppEffectCommit 0;     
	"dynamicBlur" ppEffectAdjust [0.0];  
	"dynamicBlur" ppEffectCommit 5;  
	[] remoteExec ["PLAYER_KIA",2];
	
	sleep 5;
	_unit setCaptive false;
	_unit allowDamage false;
};



//Damage handler
if (RESPAWN_ENABLED) then{

	if (isMultiplayer) then {
		// Add tickets to the player
		if (NUMBER_RESPAWN != -1) then {
			[_player, NUMBER_RESPAWN, false] call BIS_fnc_respawnTickets;
		};
		REMAINING_RESPAWN = NUMBER_RESPAWN;

		[SIDE_FRIENDLY, getMarkerPos "marker_base","Base"] call BIS_fnc_addRespawnPosition;
		
		[_player] call fnc_HandleRespawnBase;

		_loadout = getUnitLoadout _player;
	     _player addMPEventHandler ["MPRespawn", {
			params ["_unit", "_corpse"];
			[_unit, [missionNamespace, "inventory_var"]] call BIS_fnc_loadInventory;
			_unit setVariable["marker", MARKER_PLAYER, true];
			if (NUMBER_RESPAWN != -1) then {
				REMAINING_RESPAWN = [_unit,nil,true] call BIS_fnc_respawnTickets;
				if (REMAINING_RESPAWN == -1)exitWith{  endMission "LOSER";  };
			};
			_player setUnitLoadout _loadout;
			[_unit] spawn fnc_HandleRespawnBase;
		}];

		_player addMPEventHandler ["MPKilled",{
			params ["_unit"	];
			[_unit, [missionNamespace, "inventory_var"]] call BIS_fnc_saveInventory;
			[] remoteExec ["PLAYER_KIA",2];
			PLAYER_ALIVE = false;
			// Delete the marker with a little delay
			[_unit] spawn {
				params["_unit"];
				sleep 10;
				_unit call fnc_deletemarker;
			};
		}];

	} else {
		
		// Disable team switching
		enableTeamSwitch false;

		// In Singleplayer
		[_player] call fnc_HandleRespawnBase;

		// Prevent ACE to do bullshit
		_player removeAllEventHandlers "HandleDamage";
		_player addEventHandler["HandleDamage",{
			params [
				"_unit",			// Object the event handler is assigned to.
				"_hitSelection",	// Name of the selection where the unit was damaged. "" for over-all structural damage, "?" for unknown selections.
				"_damage",			// Resulting level of damage for the selection.
				"_source",			// The source unit (shooter) that caused the damage.
				"_projectile",		// Classname of the projectile that caused inflicted the damage. ("" for unknown, such as falling damage.) (String)
				"_hitPartIndex",	// Hit part index of the hit point, -1 otherwise.
				"_instigator",		// Person who pulled the trigger. (Object)
				"_hitPoint"			// hit point Cfg name (String)
			];

			// Reducing damage with a factor of 3
			_damage = 0.9 min (_damage * 0.6);
			if (_damage >= .9 && lifeState _unit == "HEALTHY")then{
				PLAYER_ALIVE = false;
				_unit setUnconscious true;
				addCamShake [15, 6, 0.7];
				[_unit] spawn fnc_HandleRespawnSinglePlayer;
				_damage = .9;
				_unit setDamage .9;
				_unit playActionNow "agonyStart";
			} else {
				if (lifeState _unit != "HEALTHY")then{
					_damage = .9;
					_unit setDamage .9;
				};
			};
			
			_damage;
		}];
	};
}else{
	// If nothing activated, just use the vanilla system
	_player addMPEventHandler ["MPKilled",{
		params [	"_unit"	];
		PLAYER_ALIVE = false;
		[] remoteExec ["PLAYER_KIA",2];
	}];
};
