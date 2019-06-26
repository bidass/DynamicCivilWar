/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */

params["_unit","_score"];

// Always executed on server side
if (!isServer) exitWith{};
if (isNil '_unit') exitWith{false};
if (isnull _unit) exitWith{false};
if (_score == 0) exitWith{};
/*
_startScore = _unit getVariable["DCW_Friendliness",50];
_unit setVariable["DCW_Friendliness",(0 max (100 min (_startScore + _score))), true];
*/
// Get the closest marker
_compound = ([position _unit,false,"any"] call DCW_fnc_findNearestMarker);
[_compound,_score,0] spawn DCW_fnc_setCompoundSupport;