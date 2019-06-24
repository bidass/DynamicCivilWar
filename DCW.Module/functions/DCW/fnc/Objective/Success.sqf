/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */

private _objWithTask = _this;
private _task = "";
private _taskName = "";

// Success
if (!isServer) exitWith{hint format["fnc_success executed on the client %1 ;/", _objWithTask getVariable["DCW_Task",""]]; };

//Task type unknown
if (_objWithTask getVariable["DCW_Type",""] == "") exitWith { false };

//Task already successful
if (!(_objWithTask getVariable["DCW_IsIntel",false])) exitWith {false};

_task = _objWithTask getVariable["DCW_Task",""];

// Silently create a task if not exists
if (_task == "") then {
    [_objWithTask,false] call fnc_CreateTask;
    _task = _objWithTask getVariable["DCW_Task",""];
};

_taskName = ((_task call BIS_fnc_taskDescription) select 1) select 0;

// Spawn task successful on each client
[[_task,_taskName,_objWIthTask],{
    params["_task","_taskName","_objWithTask"];
    [_task, "SUCCEEDED", true] call BIS_fnc_taskSetState;
    [(leader GROUP_PLAYERS), format["Task done : %1",_taskName],true] call fnc_Talk;
     sleep 20;
    [_task,true] call BIS_fnc_deleteTask;
}] remoteExec ["spawn", GROUP_PLAYERS,false];

//Custom callback
[_objWithTask,_objWithTask getVariable["DCW_Reputation",0]] remoteExec ["fnc_updateRep",2];
if (_objWithTask getVariable["DCW_Bonus",0] > 0) then{
    [GROUP_PLAYERS,_objWithTask getVariable["DCW_Bonus",0],false,leader GROUP_PLAYERS] call fnc_updateScore;
};

//Delete the task after success.
_objWithTask getVariable["DCW_MarkerIntel",""] setMarkerColor "ColorGreen";
_objWithTask setVariable["DCW_Task","", true];
_objWithTask setVariable["DCW_Type",""];
_objWithTask setVariable["DCW_IsIntel",false];
_objWithTask setVariable["DCW_IsIntelRevealed",false];

true;