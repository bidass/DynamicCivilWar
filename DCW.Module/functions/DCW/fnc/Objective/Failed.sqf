/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */

private _unitWithTask = _this;

if (isNil '_unitWithTask') exitWith{false};
if (isnull _unitWithTask) exitWith{false};
if (_unitWithTask getVariable["DCW_IsIntelRevealed",false])then{
    _unitWithTask setVariable["DCW_IsIntelRevealed",false];
    deleteMarker(_unitWithTask getVariable["DCW_MarkerIntel",""]);
    [_unitWithTask getVariable["DCW_Task",""], "FAILED",true] remoteExec ["BIS_fnc_taskSetState",GROUP_PLAYERS];
};