params["_unit"];

if (MEDEVAC_State == "menu") then {
	// Delete all useless commmenu item
	MEDEVAC_MENU_LASTID = [_unit, "Medevac"] call BIS_fnc_addCommMenuItem;
};

if (MEDEVAC_State == "inbound") then{
	MEDEVAC_action = _unit addAction ["<t color='#000'>Abort medevac</t>", { 
		params["_unit","_actionId"];
		_unit removeAction MEDEVAC_action;
		MEDEVAC_State = "aborted";
		publicVariableServer "MEDEVAC_State";
	}];
	publicVariableServer "MEDEVAC_ACTION";
};