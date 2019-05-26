
/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 * Show chat
 */
_talker = _this select 0;
_say = _this select 1;
_sound = _this select 2;
_layer = round (random 99999);
_this pushBack _layer;

// Queuing conversation
TALK_QUEUE pushback _this;
waitUntil { sleep .2; TALK_QUEUE select 0 isEqualTo _this};

_side = side _talker;
_color = "#E0E0E0";
if (_side == CIVILIAN) then {
	_color = '#c6b32b';
}else{
	if (_side == RESISTANCE) then {
		_color = '#549c66';
	}else{
		if (_side == WEST) then {
			_color = '#1a657b';
		}else{
			if (_side == EAST) then {
				_color = '#d22b2f';
			};
		};
	};
};


/*
if (_sound) then {
	[] spawn { playSound (RADIO_CHAT_LIST call BIS_fnc_selectRandom); };
};*/


// Create display and control
disableSerialization;
_layer cutrsc ["rscDynamicText","plain"];
_display = displayNull;
waitUntil {_display = uiNamespace getVariable "BIS_dynamicText"; !(isNull _display)};
_ctrl = _display displayCtrl 9999;
uiNamespace setVariable ["BIS_dynamicText", displayNull];
_ctrlBackground = _display ctrlCreate ["RscText",9999];

// Position control
 _w = 0.7 * safeZoneW;
 _x = safeZoneX + (0.15 * safeZoneW );
 _y = safeZoneY + (0.75 * safeZoneH);
 _h = safeZoneH;


// Show subtitle
_text = parseText format ["<t align = 'center' shadow = '2' size = '.8'><t color = '%1'>%2</t></t><br /><t align = 'center' shadow = '1' size = '.63'><t color = '#E0E0E0'>%3</t></t>",_color,name _talker,_say];
_ctrl ctrlSetStructuredText _text;
MESS_HEIGHT = ctrlTextHeight _ctrl;
MESS_SHOWN = true;

_ctrl ctrlSetPosition [_x,.95*_y,_w,_h];
_ctrl ctrlCommit 0;
_ctrl ctrlSetPosition [_x,_y,_w,_h];

// Hide control
_ctrl ctrlSetFade 0;
_ctrl ctrlCommit .3;

playSound "FD_CP_Clear_F";

_talker setVariable["DCW_speak",true];
_talker setRandomLip true;
sleep ((count(_say)/10) max 2);
_talker setRandomLip false;
_talker setVariable["DCW_speak",false];



 if (count TALK_QUEUE > 1) then {
	TALK_QUEUE = TALK_QUEUE - [_this];
	MESS_SHOWN = false;
	waituntil {MESS_SHOWN || count TALK_QUEUE == 0};
	_ctrl ctrlSetPosition [_x,1.1*MESS_HEIGHT + _y,_w,_h];	
	_ctrl ctrlSetFade .4;
	_ctrl ctrlCommit .3;
	sleep ((count((TALK_QUEUE select 0) select 1)/10) max 2);
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit .3;
} else {
	_ctrl ctrlSetFade 1;
	_ctrl ctrlCommit .3;
	sleep .3;
	// remove talk queue
	TALK_QUEUE = TALK_QUEUE - [_this];
	MESS_SHOWN = false;
};

// Hide subtitle
ctrlDelete _ctrl;