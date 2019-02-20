/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */

private ["_timer","_rndMarker","_rndPos","_radius","_newPos"];
params ["_unit"];

_unit setSpeedMode "LIMITED";
_unit forceWalk  true;

while { alive _unit && group _unit != group player }do{

    _newPos = [getPos player, 1, 250, 3, 0, 20, 0] call BIS_fnc_FindSafePos;
    group _unit move _newPos;
    waitUntil {sleep 5;unitReady _unit || _unit distance _newPos < 2 };
    [_unit] call fnc_randomAnimation;
   
    _rndMarker = ([position _unit] call fnc_findNearestMarker) select 0;
    
    _rndPos = getMarkerPos _rndMarker;
    _radius = (getMarkerSize _rndMarker) select 0;
    _newPos = [_rndPos, 1, _radius, 3, 0, 20, 0] call BIS_fnc_FindSafePos;
    group _unit move _newPos;
    
    waitUntil {sleep 5;unitReady _unit || _unit distance _newPos < 2 };
    [_unit] call fnc_randomAnimation;
   
    _potentialIntel = [];
    {
        if (_x select 2)then{
            {
                if (!(_x getVariable["DCW_IsIntelRevealed",false]) && _x getVariable["DCW_IsIntel",false] && _newPos distance _x < 500)then{
                    _potentialIntel pushBack _x;
                };
            } foreach (_x select 5);
        };
    } forEach MARKERS;
    if (count _potentialIntel > 0 ) then {
        _newPos = [getPos (_potentialIntel call BIS_fnc_selectrandom), 1, 10, 1, 0, 20, 0] call BIS_fnc_FindSafePos;
        group _unit move _newPos;
         waitUntil {sleep 5;unitReady _unit || _unit distance _newPos < 2 };
         [_unit] call fnc_randomAnimation;
    };

    sleep 5;
	[_unit] call fnc_gotomeeting;
    sleep 5;
};

_unit forceWalk false;