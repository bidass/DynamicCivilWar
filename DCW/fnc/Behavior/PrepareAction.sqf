/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */


//Menote le mec;
addActionHandcuff =  {
    _this addAction["Capture him",{
        _man  = (_this select 0);
        _man removeAllEventHandlers "FiredNear";
        _man  setVariable["civ_affraid",false];

        sleep .2;
        _man switchMove "";
        sleep .2;
        (_this select 1) playActionNow "PutDown";
        _man SetBehaviour "CARELESS";
        _man setCaptive true;
        [_man,-4] call fnc_updateRep;

        //Handle weapon states
        _rifle = primaryWeapon _man; 
        if (_rifle != "") then {
            _man action ["dropWeapon", _man, _rifle];
            waitUntil {animationState _man == "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" || time > 3}; 
            removeAllWeapons _man; 
        };

        _pistol = handgunWeapon _man; 
        if (_pistol != "") then {
            _man action ["dropWeapon", _man, _pistol];
            waitUntil {animationState _man == "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" || time > 3}; 
            removeAllWeapons _man; 
        };

        _man action ["Surrender", _man]; 
        _man disableai "ANIM"; 
        _man disableAI "MOVE"; 

        removeAllActions _man;

        _man call addActionLiberate;
        _man call addActionLookInventory;
        hint "Civilian captured";	   
        [_man] call CIVIL_CAPTURED;

    },nil,1.5,true,true,"","true",3,false,""];
};


addActionGiveUsAHand =  {
    _this addAction["Give us a hand (20 points/10 minutes)",{
        _man  = (_this select 0);
        _talker  = (_this select 1);
        _action  = (_this select 2);

         if (!([GROUP_PLAYER,20] call fnc_afford)) exitWith {[_man,"You need more money !",false] call fnc_talk;false;};
         [_man,"Ok, we're taking your flank",false] spawn fnc_talk;

        {
            _x removeAction _action;
            _x addAction["Stop following us",{
                _man  = (_this select 0);
                _talker  = (_this select 1);
                _action  = (_this select 2);
                [_man,"Understood sir !",false] spawn fnc_talk;

                 {
                    _x removeAction _action;
                    _x setVariable ["follow_player",false];
                    _x remoteExec ["addActionGiveUsAHand"];
                } foreach units group _man;
            }];
        } foreach units group _man;

        _talker playActionNow "PutDown";
        // Make follow us
        _group =  group _man ;
        [_group,_talker] spawn {
            params["_group","_talker"];
            (leader _group) setVariable["follow_player",true];
            _wp1 = _group addWaypoint [[0,0,0],0];
            _wp1 setWaypointType "MOVE";
            while {alive _talker && leader _group getVariable["follow_player", false]} do {
                _wp1 setWaypointPosition [(_talker ModelToWorld [random 25,-20,0]), 0];
                _group setCurrentWaypoint _wp1;
                sleep 20;
            };
        };

    },nil,12,true,true,"","true",3,false,""];
};

addActionLiberate =  {
    _this addAction["Liberate him",{
        _man  = (_this select 0);
        _talker  = (_this select 1);
        _action  = (_this select 2);
        removeAllActions _man;
        _talker playActionNow "PutDown";
        [_man] call fnc_handlefiredNear;
        [_man] call fnc_addCivilianAction;
        _man SetBehaviour "AWARE";
        _man setCaptive false;
        _man switchMove ""; 
        _man enableai "ANIM"; 
        _man enableai "MOVE"; 
        [_man,2] call fnc_updateRep;
    },nil,1.5,true,true,"","true",3,false,""];
};


addActionLookInventory = {
    _this addAction["Search in gear",{
        params["_unit","_human","_action"];
        _unit removeAction _action;
        if (_unit getVariable["DCW_Suspect",false])then{
            for "_i" from 1 to 3 do {_unit addItemToUniform "1Rnd_HE_Grenade_shell";};
            [_human,"Holy shit ! This man is carrying material for IED purposes !",true] remoteExec ["fnc_talk"];
            [_unit,1] call fnc_updateRep;   
            [_unit,30] call fnc_updateScore;   
            RemoveAllActions _unit;
        }else{
            [_unit,-1] call fnc_updateRep;   
        };
        sleep .4;
        if (alive _unit) then {
            _human action ["Gear", _unit];
        };

    },nil,1.5,true,true,"","true",3,false,""];
};

addActionHalt = {
    _this addAction["Say hello",{
        params["_unit","_asker","_action"];
        _asker playActionNow "GestureFreeze";
        _unit stop true;
        [_asker,"Hello sir !",false] call fnc_Talk;
        if (!weaponLowered _asker) exitWith { 
            [_unit,"I don't talk to somebody pointing his gun on me ! Go away !",false] call fnc_Talk;
            _unit playActionNow "gestureNo";
            [_asker,"I'm sorry, sir !",false] call fnc_Talk;
            [_unit,-2] call fnc_updateRep;
            _unit stop false;
            false; 
        };
        
        _unit removeAction _action;
        _unit doWatch _asker;
        sleep 1;
        _unit playActionNow "GestureHi";
        [_unit,format["Hi ! My name is %1.", name _unit],false] call fnc_Talk;
        sleep 1.5;
        _unit disableAI "MOVE";
        sleep 30;
        _unit stop false;
        _unit enableAI "MOVE";
        _unit call addActionHalt;
    },nil,2.5,true,true,"","true",20,false,""];
};

addActionDidYouSee = {
    //Try to gather intel
    _this addAction["Did you see anything recently ?",{
    params["_unit","_talker","_action"];
        _unit removeAction _action;

        if (_unit getVariable["DCW_Friendliness",50] < 40) exitWith {
            [_unit,-2] call fnc_updateRep;
            [_unit,"Don't talk to me !",false] call fnc_Talk;
            false;
        };
        
        [_talker,"Did you see anything recently ?", false] call fnc_Talk;
        private _data = _unit targetsQuery [objNull,ENEMY_SIDE, "", [], 0];
        sleep 1;
        _data = _data select {side group (_x select 1) == ENEMY_SIDE};
        if (count _data == 0) exitWith {
            [_unit, "I saw nothing...",false] call fnc_Talk;
        };
        if (count _data > 3) then { _data = [_data select 0] + [_data select 1] + [_data select 2];};
        
        [_unit,format["I saw %1 enemies...",count _data],false] call fnc_Talk;
        _markers = [];
        {
            _enemy = _x select 1;
            if (alive _enemy) then {
                _nbMeters = round((_enemy distance _unit)/10)/100;
                _ang = ([_unit,_enemy] call BIS_fnc_dirTo) + 11.25; 
                if (_ang > 360) then {_ang = _ang - 360};
                _points = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"];
                _num = floor (_ang / 22.5);
                _compass = _points select _num;
                _type = getText (configFile >> "cfgVehicles" >> typeOf vehicle _enemy >> "displayName");
                [_unit, format["I saw a %1 %2 %3km away, %4minutes ago ", _type,_compass,_nbMeters,ceil((_x select 5)/60)],false] call fnc_Talk;
                _marker = createMarkerLocal [format["enemyviewed-%1", random 50], position _enemy];
                _marker setMarkerShapeLocal "ICON";
                _marker setMarkerTypeLocal "mil_dot";
                _marker setMarkerColorLocal "ColorRed";
                _marker setMarkerTextLocal format["%1", _type];
                _markers pushback _marker;
                sleep .3;
            };
        } forEach _data;

        [_unit,"I marked their positions on your map. Help us please !",false] call fnc_Talk;
        [_unit,1] call fnc_updateRep;
        [_talker,"Thanks a lot !",false] call fnc_Talk;
        [_unit,"You're welcome !",false] call fnc_Talk;
        sleep 240;
        { deleteMarker _x; }foreach _markers;
        if (alive _unit) then {
            _unit call addActionDidYouSee;
        };
    },nil,1.5,true,true,"","true",3,false,""];
};


    

AddActionFeeling = {
    //Try to gather intel
    _this addAction[format["What's your feeling about the %1's presence in %2",getText(configfile >> "CfgFactionClasses" >> format["%1",faction (allPlayers select 0)] >> "displayName"),worldName] ,{
        params["_unit","_talker","_action"];
            [_unit,1] call fnc_updateRep;
            _unit removeAction _action;
            _message = "No problem, if you stay calm";
            if (CIVIL_REPUTATION  < 10) then {
                _message = "Go away, before I call all my friends to kick your ass!";
            }else{
                if (CIVIL_REPUTATION  < 20) then {
                _message = "You crossed a line... I would never help you guys ! ";
                }else{
                    if (CIVIL_REPUTATION  < 30) then {
                    _message = "It's getting really bad... ";
                    }else{
                        if (CIVIL_REPUTATION  < 40) then {
                            _message = "You're not welcome here... ";
                        }else{
                            if (CIVIL_REPUTATION  < 50) then {
                                _message = "Ou relations are getting worst";
                            }else{
                            if (CIVIL_REPUTATION  < 55) then {
                                    _message = "You should do more to help us !";
                                }else{
                                    if (CIVIL_REPUTATION  < 70) then {
                                        _message = "Less hostile around here, it's getting better here.";
                                    }else{
                                        if (CIVIL_REPUTATION  < 85) then {
                                            _message = "You made a great job here ! Thanks for everything.";
                                        }else{
                                            if (CIVIL_REPUTATION  <= 100) then {
                                                _message = "Have a drink my friend ! Grab a bier ! My home is yours !";
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };

            [_unit,_message,false] call fnc_Talk;
            sleep 120;
            _unit call AddActionFeeling;

        },nil,1.5,true,true,"","true",3,false,""];
};



addActionGetIntel = {
    //Try to gather intel
   _this addAction["Gather intel (15 minutes)",{
       params["_unit","_talker","_action"];

        //Suspect
        _isSuspect=_unit getVariable ["DCW_Suspect",false];

         if (_unit getVariable["DCW_Friendliness",50] < 35 ) exitWith {
            [_unit,-3] call fnc_updateRep;
           [_unit,"Don't talk to me !",false] call fnc_Talk;
           false;
        };

        _unit removeAction _action;
        if (!weaponLowered _talker)then{
            _talker  action ["WeaponOnBack", _talker];
        };
        showCinemaBorder true;
        _camPos = _talker modelToWorld [-1,-0.2,1.9];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _cam camSetPos _camPos;
        _cam camSetTarget _unit;
        _cam camSetFov 1.0;
        _cam camCommit 0;
        _unit stop true;
        _unit lookAt _talker;
        _talker lookAt _unit;

        sleep 1;

        _unit disableAI "MOVE";

        //Talking with the fixed glitch
        _anim = format["Acts_CivilTalking_%1",ceil(random 2)];
        _unit switchMove _anim;

        titleCut ["15 minutes later...", "BLACK OUT", 1];

        sleep 1;

        skipTime .25;

        if (_isSuspect)then{
            [_unit,"Sorry, I have plenty work to do !",false] call fnc_Talk;
        }else{
            _res = [_unit,_talker] call fnc_GetIntel;
            [_unit,(_res select 1),false] call fnc_Talk;
            [_unit,3] call fnc_updateRep;
        };

        sleep 1;

        titleCut ["15 minutes later...", "BLACK IN", 4];

        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;

         waitUntil{animationState _unit != _anim};
        _unit switchMove "";

        sleep 10;
        _unit enableAI "MOVE";
        _unit stop false;

    },nil,1.5,true,true,"","true",3,false,""];
};


addActionRally = {
    //Try to make him a friendly
   _this addAction["Try to rally (30 minutes/5 points)",{
       params["_unit","_talker","_action"];
       
        if (!([GROUP_PLAYER,5] call fnc_afford)) exitWith {[_unit,"You need more money !",false] call fnc_talk;false;};

        _unit removeAction _action;
        showCinemaBorder true;
        _camPos = _talker modelToWorld [-1,-0.2,1.9];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _cam camSetPos _camPos;
        _cam camSetTarget _unit;
        _cam camSetFov 1.0;
        _cam camCommit 0;
        _unit stop true;
        _unit lookAt _talker;
        _talker lookAt _unit;
        sleep 1;
        _unit disableAI "MOVE";
        titleCut ["30 minutes later...", "BLACK OUT", 1];
        sleep 1;
        skipTime .50;
        sleep 2;
        titleCut ["30 minutes later...", "BLACK IN", 4];
        sleep 3;
        _unit stop false;
        _unit enableAI "ALL";
        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;

        //Suspect
        _isSuspect = _unit getVariable ["DCW_Suspect",false];
        
       
       if(random 100 < PERCENTAGE_FRIENDLY_INSURGENTS && !_isSuspect) then {
            [_unit,"Ok, I'm in !",false] call fnc_Talk;
            [_unit,SIDE_CURRENT_PLAYER] call fnc_BadBuyLoadout;
            [_unit,3] call fnc_updateRep;
            sleep 5;
            [_unit] joinSilent grpNull;
            [_unit] joinSilent (group _talker);
        }else{
            if (_isSuspect)then{
                [_unit,"No thanks",false] call fnc_Talk;
            }else{
                [_unit,"Sorry, but I have a family ! No way I get back to war...", false] call fnc_Talk;
            };

            [_unit,-1 ] call fnc_updateRep;
        };
    },nil,1.5,true,true,"","true",3,false,""];
};



addActionFindChief = {
    params["_unit","_chief"];
    //Try to gather intel
   _unit addAction["Where is your chief ?",{
        params["_unit","_talker","_action"];
        _chief = (_this select 3) select 0;
        if(alive _chief)then{
            [_unit,format["I marked you the exact position where I last saw %1", name _chief],false] call fnc_Talk;
            _marker = createMarkerLocal [format["chief-%1", random 50], getPosWorld _chief];
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal "mil_dot";
            _marker setMarkerColorLocal "ColorGreen";
            _marker setMarkerTextLocal "LocalChief";
        }else{
            [_unit,"Our chief is no more... Fucking war !",false] call fnc_Talk;
        };
    },[_chief],1.5,true,true,"","true",3,false,""];
};


addActionLeave = {
    _this addAction["Go away !",{
        params["_unit","_asker"];
        [_unit,-3] call fnc_updateRep;
        RemoveAllActions _unit;
        _asker playActionNow "gestureGo";
        [_asker,"Sorry sir, you must leave now, go away !",false] call fnc_Talk;
        _pos = [getPos _unit, 1000, 1100, 1, 0, 20, 0] call BIS_fnc_FindSafePos;
        _unit stop false;
        _unit forceWalk false;
        _unit forceSpeed 10;
        _unit move _pos;
    },nil,3.5,true,true,"","true",3,false,""];
};

