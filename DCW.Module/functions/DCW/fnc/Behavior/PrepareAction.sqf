/**
 * DYNAMIC CIVIL WAR
 * Created: 2017-11-29
 * Author: BIDASS
 * License : GNU (GPL)
 */



addActionJoinAsAdvisor = {
      _this addaction ["<t color='#FF0000'>Recruit him as a military advisor (-30pts)</t>",{
         params["_unit","_talker","_action"];
         if (!(_this call fnc_startTalking)) exitWith {};
         if ({_x getVariable["DCW_advisor",false]}count (units GROUP_PLAYERS) >= 2) exitWith {[_talker,"You can't recruit more than two military advisors...",false] call fnc_talk;_this call fnc_endTalking;false;};
         if (!([GROUP_PLAYERS,30] call fnc_afford)) exitWith {[_talker,"I need more points !",false] call fnc_talk;_this call fnc_endTalking;false;};
      
        _talker playActionNow "GestureFreeze";
        _unit playActionNow "GestureHi";
       
        sleep .3;
        _unit stop true;
        [_talker,"Hi buddy, I would need a military advisor, are you in ?!",false] call fnc_Talk;
        [_unit,"I'm in ! Let's go",false] call fnc_Talk;
        _unit removeAction _action;
        sleep .3;
        _unit setVariable["DCW_advisor", true, true];
        [_unit] join GROUP_PLAYERS;
        _this call fnc_endTalking;

    },nil,1,true,true,"","true",3,false,""];
};

//Menote le mec;
addActionHandCuff =  {
    _this addaction ["<t color='#FF0000'>Capture him</t>",{
        _unit  = (_this select 0);
        _unit removeAllEventHandlers "FiredNear";
        _unit  setVariable["civ_affraid",false];

        sleep .2;
        _unit switchMove "";
        sleep .2;
        (_this select 1) playActionNow "PutDown";
        _unit SetBehaviour "CARELESS";
        _unit setCaptive true;
        [_unit,-4] remoteExec ["fnc_updateRep",2];

        //Handle weapon states
        _rifle = primaryWeapon _unit; 
        if (_rifle != "") then {
            _unit action ["dropWeapon", _unit, _rifle];
            waitUntil {animationState _unit == "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" || time > 3}; 
            removeAllWeapons _unit; 
        };

        _pistol = handgunWeapon _unit; 
        if (_pistol != "") then {
            _unit action ["dropWeapon", _unit, _pistol];
            waitUntil {animationState _unit == "amovpercmstpsraswrfldnon_ainvpercmstpsraswrfldnon_putdown" || time > 3}; 
            removeAllWeapons _unit; 
        };

        _unit action ["Surrender", _unit]; 
        _unit disableai "ANIM"; 
        _unit disableAI "MOVE"; 

        _unit remoteExec ["RemoveAllActions",0];

        _unit call addActionLiberate;
        _unit call addActionLookInventory;
        hint "Civilian captured";	   
        [_unit] remoteExec ["CIVIL_CAPTURED",2];

    },nil,9,false,true,"","true",3,false,""];
};


addActionInstructor = {
    
    if (!isMultiplayer)then {
        _this addaction ["<t color='#FF0000'>Savegame</t>",{
        saveGame;
        },nil,1.5,false,true,"","true",3,false,""];
    };

     _this addaction ["<t color='#FF0000'>Briefing</t>",{
        params["_unit"];
        if (!(_this call fnc_startTalking)) exitWith {};
        [_unit, "Your main objective is to seek and neutralize an enemy commander hidden somewhere..."] call fnc_talk;
        [_unit, "He will be always moving on the map, hiding in forestry area or compounds."] call fnc_talk;
        [_unit, "You have two way to get info about his location : interrogating civil chief in compound or interrogating one of his officers wandering on the map in trucks..."] call fnc_talk;
        [_unit, "We've located a few of these officers spreading the insurgency accross the country. It's highly recommended to neutralize them"] call fnc_talk;
        [_unit, "The key path is to make the population always supporting you. Giving people food, medicine and military training will make our investigations easier."] call fnc_talk;
        [_unit, "Alright guys ? Any question ? Dismiss !"] call fnc_talk;
        _this call fnc_endTalking;
    },nil,1,true,true,"","true",3,false,""];
};

addActionGiveUsAHand =  {
    _this select 0 addaction ["<t color='#FF0000'>Give us a hand (20 points/10 minutes)</t>",{
        _unit  = (_this select 0);
        _talker  = (_this select 1);
        _action  = (_this select 2);

         if (!(_this call fnc_startTalking)) exitWith {};
         if (!([GROUP_PLAYERS,20] call fnc_afford)) exitWith {_this call fnc_endTalking;[_unit,"You need more points !",false] call fnc_talk;false;};
         [_unit,"Ok, we're taking your flank",false] spawn fnc_talk;
         _this call fnc_endTalking;

        {
            [_x,_action] remoteExec ["removeAction",2];
            [_x,["Stop following us",{
                _unit  = (_this select 0);
                _talker  = (_this select 1);
                _action  = (_this select 2);
                [_unit,"Understood sir !",false] spawn fnc_talk;

                 {
                    [_x,_action] remoteExec ["removeAction",2];
                    _x setVariable ["follow_player",false];
                    [_x] remoteExec ["addActionGiveUsAHand"];
                } foreach units group _unit;
            }]] remoteExec ["addAction",2];
        } foreach units group _unit;

        _talker playActionNow "PutDown";
        // Make follow us
        _group =  group _unit ;
        [_group,_talker] spawn {
            params["_group","_talker"];
            (leader _group) setVariable["follow_player",true];
            _wp1 = _group addWaypoint [[0,0,0],0];
            _wp1 setWaypointType "MOVE";
            _wp1 setWaypointBehaviour "AWARE";
            while {alive _talker && leader _group getVariable["follow_player", false]} do {
                _wp1 setWaypointPosition [(_talker ModelToWorld [random 25,-20,0]), 0];
                _group setCurrentWaypoint _wp1;
                sleep 20;
            };
        };
         

    },nil,1,false,true,"","true",5,false,""];
};

addActionLiberate =  {
    _this addaction ["<t color='#FF0000'>Liberate him</t>",{
        _unit  = (_this select 0);
        _talker  = (_this select 1);
        _action  = (_this select 2);
        if (!(_this call fnc_startTalking)) exitWith {};
        [_talker,"Go away now ! asshole !",false] call fnc_Talk;
        if(side _unit != SIDE_CIV) then {
		    [_unit] joinSilent createGroup SIDE_CIV;
        };
        _unit remoteExec ["removeAllActions",0];
        [_talker,"PutDown"] remoteExec ["playActionNow"];
        //[_unit] call fnc_handlefiredNear;
        //[_unit] call fnc_addCivilianAction;
        _this call fnc_endTalking;
        _unit SetBehaviour "AWARE";
        _unit setCaptive false;
        _unit switchMove ""; 
        _unit enableai "ANIM"; 
        _unit enableai "MOVE"; 
        if (side _unit == SIDE_CIV) then {
            [_unit,2] remoteExec ["fnc_updateRep",2];
        };
        _pos = [getPos _unit, 1000, 1100, 1, 0, 20, 0] call BIS_fnc_findSafePos;
        _unit stop false;
        _unit forceWalk false;
        _unit forceSpeed 10;
        _unit move _pos;

            
    },nil,1,false,true,"","true",3,false,""];
};


addActionLookInventory = {
      _this addaction ["<t color='#FF0000'>Search in gear</t>",{
        params["_unit","_human","_action"];
        _unit removeAction _action;
        if (_unit getVariable["DCW_Suspect",false])then{
            for "_i" from 1 to 3 do {_unit addItemToUniform "1Rnd_HE_Grenade_shell";};
            [_human,"Holy shit ! This man is carrying material for IED purposes !",true] remoteExec ["fnc_talk"];
            [_unit,1] remoteExec ["fnc_updateRep",2];   
            [GROUP_PLAYERS,30,false,_human] remoteExec ["fnc_updateScore",2];   
            _unit remoteExec ["RemoveAllActions",0];
        }else{
            [_unit,-1] remoteExec ["fnc_updateRep",-2];   
        };
        sleep .4;
        if (alive _unit) then {
            _human action ["Gear", _unit];
        };

    },nil,5,false,true,"","true",3,false,""];
};

addActionHalt = {
      _this addaction ["<t color='#FF0000'>Say hello</t>",{
        params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};
        
        _talker remoteExec ["GestureFreeze"];
        
        _unit stop true;

        [_talker,"Hello sir !",false] call fnc_Talk;
        
        if (!weaponLowered _talker) exitWith { 
            [_unit,"I don't talk to somebody pointing his gun on me ! Go away !",false] call fnc_Talk;
            _unit playActionNow "gestureNo";
            [_talker,"I'm sorry, sir !",false] call fnc_Talk;
            [_unit,-2] remoteExec ["fnc_updateRep",2];
            _unit stop false;
            _this call fnc_endtalking;
            false; 
        };
        
        _unit removeAction _action;
        _unit call addActionDidYouSee;
        _unit call addActionFeeling;
        _unit call addActionGetIntel;
        _unit call addActionRally;
        _unit call addActionSupportUs;
        if ( _unit getVariable["DCW_Chief",objNull] != objNull && alive (_unit getVariable["DCW_Chief",objNull])) then {
            [_unit,_unit getVariable["DCW_Chief",objNull]]  call addActionFindChief;
        };

        sleep 1;
        _unit playActionNow "GestureHi";
        [_unit,format["Hi ! My name is %1.", name _unit],false] spawn fnc_Talk;
        
        _unit disableAI "MOVE";
        sleep 0.5;

        _this call fnc_endtalking;

        waitUntil { _talker distance _unit > 13; sleep 4; };
            
        _unit stop false;
        _unit enableAI "MOVE";

        RemoveAllActions _unit;

        [_unit] call fnc_addCivilianAction;

    },nil,12,false,true,"","true",6,false,""];
};

addActionDidYouSee = {
    //Try to gather intel
     _this addaction ["<t color='#FF0000'>Did you see anything recently ?</t>",{
    params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};

        _unit removeAction _action;

        /*if (_unit getVariable["DCW_Friendliness",50] < 40) exitWith {
            [_unit,-2] remoteExec ["fnc_updateRep",2];
            [_unit,"Don't talk to me !",false] call fnc_Talk;
            false;
        };*/
        
        [_talker,"Did you see anything recently ?", false] call fnc_Talk;
        private _data = _unit targetsQuery [objNull,SIDE_ENEMY, "", [], 0];
        sleep 1;
        _data = _data select {side group (_x select 1) == SIDE_ENEMY};

        if (count _data == 0) exitWith {
            [_unit, "I saw nothing...",false] call fnc_Talk;
            _this call fnc_endtalking;
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
        [_unit,1] remoteExec ["fnc_updateRep",2];
        [_talker,"Thanks a lot !",false] call fnc_Talk;
        _this call fnc_endtalking;
        sleep 240;
        { deleteMarker _x; }foreach _markers;
        if (alive _unit) then {
            _unit remoteExec ["addActionDidYouSee"];
        };

    },nil,5,false,true,"","true",2.5,false,""];
};

AddActionFeeling = {
    //Try to gather intel
     _this addaction [format["<t color='#FF0000'>What's your feeling about the %1's presence in %2</t>",getText(configfile >> "CfgFactionClasses" >> format["%1",faction (allPlayers select 0)] >> "displayName"),worldName] ,{
        params["_unit","_talker","_action"];
            if (!(_this call fnc_startTalking)) exitWith {};
            [_unit,1] remoteExec ["fnc_updateRep",2];
            [_unit, _action] remoteExec["removeAction"];
            _message = "No problem, if you stay calm";
            CIVIL_REPUTATION = ([position _unit,false,"any"] call fnc_findNearestMarker) select 13;
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
            _this call fnc_endtalking;
            
            sleep 120;
            
            _unit remoteExec["AddActionFeeling"];

        },nil,4,false,true,"","true",3,false,""];
};



addActionGetIntel = {
    //Try to gather intel
    _this addaction ["<t color='#FF0000'>Gather intel (15 minutes)</t>",{
       params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};

        //Suspect
        _isSuspect=_unit getVariable ["DCW_Suspect",false];

         /*if (_unit getVariable["DCW_Friendliness",50] < 35 ) exitWith {
            if (side _unit == SIDE_CIV) then {
                [_unit,-3] remoteExec ["fnc_updateRep",2];
            };  
           [_unit,"Don't talk to me !",false] call fnc_Talk;
           false;
        };*/

        _unit removeAction _action;
        if (!weaponLowered _talker)then{
            _talker action ["WeaponOnBack", _talker];
        };
        showCinemaBorder true;
        _camPos = _talker modelToWorld [-1,-0.2,1.9];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _cam camSetPos _camPos;
        _cam camSetTarget _unit;
        _cam camSetFov 1.0;
        _cam camCommit 0;
        _unit lookAt _talker;
        _talker lookAt _unit;

        sleep 1;

        //Talking with the fixed glitch
        _anim = format["Acts_CivilTalking_%1",ceil(random 2)];
        _unit switchMove _anim;

        titleCut ["", "BLACK OUT", 1];
        [parseText format ["<t font='PuristaBold' size='1.6'>15 minutes later...</t><br/>%1", daytime call BIS_fnc_timeToString], true, nil, 12, 0.7, 0] spawn BIS_fnc_textTiles;

        sleep 1;
        if (!isMultiplayer) then {
            skipTime .25;
        };
        if (_isSuspect)then{
           [_unit,["Not your business !","I must leave...","Leave me alone please...","I'm a dead man if I talk to you..."] call BIS_fnc_selectRandom,false] call fnc_Talk;
        }else{
           [_unit,_talker] remoteExec ["fnc_GetIntel",2];
           [_unit,3] remoteExec ["fnc_updateRep",2];
        };

        sleep 1;

        titleCut ["", "BLACK IN", 4];

        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;

        // Stop
        _this call fnc_endTalking;

         waitUntil{animationState _unit != _anim};
        _unit switchMove "";

        sleep 10;


    },nil,5,false,true,"","true",3,false,""];
};


addActionRally = {
    //Try to make him a friendly
    _this addaction["<t color='#FF0000'>Try to rally (30 minutes/5 points)</t>",{
       params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};
        if (!([GROUP_PLAYERS,5] call fnc_afford)) exitWith {_this call fnc_endTalking;[_unit,"You need more money !",false] call fnc_talk;false;};

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
        titleCut ["", "BLACK OUT", 1];
        [parseText format ["<t font='PuristaBold' size='1.6'>30 minutes later...</t><br/>%1", daytime call BIS_fnc_timeToString], true, nil, 12, 0.7, 0] spawn BIS_fnc_textTiles;

        sleep 1;
        skipTime .50;
        sleep 2;
        titleCut ["", "BLACK IN", 4];
        sleep 3;
        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;

        //Suspect
        _isSuspect = _unit getVariable ["DCW_Suspect",false];
        
        _this call fnc_endTalking;
       
       if(random 100 < PERCENTAGE_FRIENDLY_INSURGENTS && !_isSuspect) then {
            _unit stop false;
            _unit enableAI "ALL";
            [_unit,"Ok, I'm in !",false] call fnc_Talk;
            [_unit,SIDE_FRIENDLY] call fnc_BadBuyLoadout;
            RemoveAllActions _unit;
            [_unit,3] remoteExec ["fnc_updateRep",2];
            [_unit] joinSilent grpNull;
            [_unit] join GROUP_PLAYERS;
        }else{
            if (_isSuspect)then{
                [_unit,"No thanks",false] call fnc_Talk;
            }else{
                [_unit,"Sorry, but I have a family ! No way I get back to war...", false] call fnc_Talk;
            };

            [_unit,-1 ] remoteExec ["fnc_updateRep",2];
        };
    },nil,2,false,true,"","true",3,false,""];
};

addActionSupportUs = {
    //Try to gather intel
     _this addaction ["<t color='#FF0000'>Give him help (2 hours/20points)</t>",{
        params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};
        _unit removeAction _action;

        if (!([GROUP_PLAYERS,20] call fnc_afford)) exitWith {_this call fnc_endTalking;[_unit,"You need more money !",false] call fnc_talk;false;};
        
        [_talker,"What are looking for ? We can provide you food, medicine, water...", false] call fnc_Talk;
        [_unit,1] remoteExec ["fnc_updateRep",(2 + floor random 2)];
        [_unit,"Thanks for your precious help !",false] call fnc_Talk;;
        [_unit,"You're welcome !",false] call fnc_Talk;
        _this call fnc_endTalking;
    },nil,1,false,true,"","true",2.5,false,""];

};


addActionFindChief = {
    params["_unit","_chief"];
    //Try to gather intel
   _unit addAction["<t color='#FF0000'>Where is your chief ?</t>",{
        params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};
        _chief = (_this select 3) select 0;
        if(alive _chief)then{
            _marker = createMarkerLocal ["localchief", getPosWorld _chief];
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal "mil_dot";
            _marker setMarkerColorLocal "ColorGreen";
            _marker setMarkerTextLocal "LocalChief";
            [_unit,format["I marked you the exact position where I last saw %1", name _chief],false] call fnc_Talk;
           
        }else{
            [_unit,"Our chief is no more... Fucking war !",false] call fnc_Talk;
        };
        _this call fnc_endTalking;
    },[_chief],7,false,true,"","true",3,false,""];
};


addActionLeave = {
     _this addaction ["<t color='#FF0000'>Go away !</t>",{
        params["_unit","_talker"];
        if (!(_this call fnc_startTalking)) exitWith {};
        [_unit,-3] remoteExec ["fnc_updateRep",2];
        _unit remoteExec ["removeAllActions",0];
        _talker playActionNow "gestureGo";
        [_talker,"Sorry sir, you must leave now, go away !",false] remoteExec ["fnc_Talk",0];
        _pos = [getPos _unit, 1000, 1100, 1, 0, 20, 0] call BIS_fnc_findSafePos;
        _unit enableAI "MOVE";
        _unit stop false;
        _unit forceWalk false;
        _unit forceSpeed 10;
        _unit move _pos;
        _this call fnc_endTalking;
    },nil,8,false,true,"","true",3,false,""];
};


fnc_ActionRest =  {
    _this addAction ["<t color='#00FF00'>Rest (3 hours)</t>", {
        params["_tent","_unit","_action"];
        if((_unit findNearestEnemy _unit) distance _unit < 100)exitWith {[_unit,"Impossible untill there is enemies around",false] call fnc_talk;};
        _tent removeAction _action;
        _newObjs = [getPos _unit,getDir _unit, compo_rest ] call BIS_fnc_objectsMapper;
        _camPos = _unit modelToWorld [.3,2.2,2];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _cam camSetPos _camPos;
        _cam camSetTarget _unit;
        _cam camSetFov 1.05;
        _cam camCommit 30;
        _unit stop true;
        sleep 2;
        _unit action ["sitdown",_unit];
        sleep 3;
        
        if (!isMultiplayer) then {
            setAccTime 120;
        };

        sleep 25;
        
        if (!isMultiplayer) then {
            setAccTime 1;
            skipTime 3;
        };

        sleep 3;
        [_unit,"Ok, let's go back to work !",false] call fnc_Talk;
        _unit action ["sitdown",_unit];

        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;

        _unit setFatigue 0;
        _unit setStamina 1;
        _unit enableStamina false;
        _unit enableFatigue false;

        { deleteVehicle _x; }foreach _newObjs;

        sleep 1;
        disableUserInput false;
        sleep 3;
        savegame;

        [_tent,_unit,_action] spawn {
            params["_tent","_unit","_action"];
            sleep 30;
            _unit enableStamina true;
            _unit enableFatigue true;
            sleep 300;
            if (isNull _tent) exitWith {};
            _tent call fnc_ActionRest;
        };
        
    },nil,1,false,true,"","if(vehicle(_this) == _this)then{true}else{false};",15,false,""];
 };




fnc_ActionCorrupt =  {
    _this addAction ["<t color='#000000'>Corrupt him (30min/-100pts)</t>",{
          params["_unit","_talker","_action"];
        if (!(_this call fnc_startTalking)) exitWith {};
         if (!([GROUP_PLAYERS,100] call fnc_afford)) exitWith {_this call fnc_endTalking; [_unit,"You need more money !", false] spawn fnc_talk;false;};

        //Populate with friendlies
        _curr = ([position _unit,false,"any"] call fnc_findNearestMarker);
    
        [_talker,"Maybe we could find an arrangement...", false] spawn fnc_talk;

        sleep 1;
        titleCut ["", "BLACK IN", 1];
        [parseText format ["<t font='PuristaBold' size='1.6'>30 minutes later...</t><br/>%1", daytime call BIS_fnc_timeToString], true, nil, 12, 0.7, 0] spawn BIS_fnc_textTiles;

        showCinemaBorder true;
        _camPos = _talker modelToWorld [-1,-0.2,1.9];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _unit disableAI "MOVE";
        titleCut ["", "BLACK OUT", 1];
        sleep 1;
        skipTime .50;
        detach _talker;
        _talker switchMove "";
        sleep 2;
        titleCut ["", "BLACK IN", 4];
        sleep 3;
        _unit stop false;
        _unit enableAI "ALL";
        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;
        
        if(_curr select 17 == "torture") then{ 
            if (!isMultiplayer) then {
                skipTime 6;
            };
		    [_unit,20] remoteExec ["fnc_updateRep",2];
            [_unit,"I accept the deal...", false] spawn fnc_talk; 
            _unit call fnc_MainObjectiveIntel;
        } else {
            [_unit,"You're wasting your time !", false] spawn fnc_talk; 
            [_unit,-10] remoteExec ["fnc_updateRep",2];
        };

        _unit removeAction _action;
        _this call fnc_endTalking;

    },nil,1,true,true,"","true",20,false,""];
};

fnc_AddActionHeal = {
    // Stabilize
    [ _this,"Heal","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa","\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_reviveMedic_ca.paa","_this distance _target <= 2","true",{
            params["_injured","_healer","_actionId"];
            if (!alive _injured) exitWith {};
            _healer playActionNow "medicStart";
            [_injured] spawn fnc_shout;
            [_healer,_injured,20] spawn fnc_spawnHealEquipement;
            _offset = [0,0,0]; _dir = 0;
            _relpos = _healer worldToModel position _injured;
            if ((_relpos select 0) < 0) then {_offset = [-0.2,0.7,0]; _dir = 90} else {_offset = [0.2,0.7,0]; _dir = 270};
            _injured attachTo [_healer, _offset];
            [_injured, _dir] remoteExec ["setDir", 0, false];
        },{
            params["_injured","_healer"];
            //_healer playActionNow "medicStart";
        
        },{
            params["_injured","_healer","_actionId"];
            _healer playActionNow "medicStop";
            detach _injured;
            _injured setUnconscious false;
            _injured setDamage 0;
            _injured setCaptive false;
            _injured stop false;
            _injured setHit ["legs", 0]; 
            deleteMarker (_injured getVariable ["DCW_marker_injured",  ""]);
            _injured setVariable ["unit_injured", false, true];
            [_injured,_healer] remoteExec ["CIVIL_HEALED",2];
            [_healer,4] remoteExec ["fnc_updateRep",2];
            _injured remoteExec ["RemoveAllActions"];
            [_healer,["Ok, this helps...","You look better now !"] call BIS_fnc_selectRandom, false] spawn fnc_talk;
            _injured;
        },{
            params["_injured","_healer"];
            _healer playActionNow "medicStop";
            detach _injured;
        },[],15,nil,true,true] remoteExec ["BIS_fnc_holdActionAdd"];

};

fnc_ActionTorture =  {
    _this addAction ["<t color='#000000'>Torture him (2 hours/Bad reputation)</t>",{
        params["_unit","_talker","_action"];
        //Populate with friendlies
        if (!(_this call fnc_startTalking)) exitWith {};

        _curr = ([position _unit,false,"any"] call fnc_findNearestMarker);
    
		[_unit,-20] remoteExec ["fnc_updateRep",2];
        [_talker,"I need an answer now !! Little piece of shit !!", false] spawn fnc_talk;

        titleCut ["", "BLACK OUT", 1];
        [parseText format ["<t font='PuristaBold' size='1.6'>2 hours later...</t><br/>%1", daytime call BIS_fnc_timeToString], true, nil, 12, 0.7, 0] spawn BIS_fnc_textTiles;

        sleep 1;

        showCinemaBorder true;
        _camPos = _talker modelToWorld [-1,-0.2,1.9];
        _cam = "camera" camcreate _camPos;
        _cam cameraeffect ["internal", "back"];
        _unit disableAI "MOVE";

        titleCut ["", "BLACK IN", 1];
        sleep 1;

        _cam camSetPos _camPos;
        _cam camSetTarget _unit;
        _cam camSetFov 1.0;
        _cam camCommit 0;
        _unit stop true;
        _unit lookAt _talker;
        _talker lookAt _unit;


        // Animation 
        _talker attachTo [_unit,[-0.9,-0.2,0]]; 
        _talker setDir (_talker getRelDir _unit); 
	    _talker switchMove "Acts_Executioner_StandingLoop";
        _talker switchMove "Acts_Executioner_Backhand";
        _unit switchMove "Acts_ExecutionVictim_Backhand";
        [_unit] call fnc_shout;
        _unit setDamage .5;
        
        sleep 3.6;
        
        // Standing loop
        _unit switchMove "Acts_ExecutionVictim_Loop";
        _talker switchMove "Acts_Executioner_StandingLoop";
        sleep 1;

        // Animation 
        _talker switchMove "Acts_Executioner_Forehand";
        _unit switchMove "Acts_ExecutionVictim_Forehand";
        [_unit] call fnc_shout;
        _unit setDamage .7;

        sleep 3.6;

        // Standing loop
        _unit switchMove "Acts_ExecutionVictim_Loop";
        _talker switchMove "Acts_Executioner_StandingLoop";

        sleep 1;
      
        titleCut ["", "BLACK OUT", 2];
        sleep 2;
        skipTime .50;
        titleCut ["", "BLACK IN", 4];
        sleep 3;
        _unit stop false;
        _unit enableAI "ALL";
        showCinemaBorder false;
        _cam cameraeffect ["terminate", "back"];
        camDestroy _cam;
        detach _talker;
        _talker switchMove "";

        if(_curr select 17 == "torture") then{ 
            if (!isMultiplayer) then {
                skipTime 6;
            };
            _unit removeAction _action;
            [_unit,"I know something ! But stop it ! Please !", false] spawn fnc_talk; 
		    [_unit,10] remoteExec ["fnc_updateRep",2];
            _unit call fnc_MainObjectiveIntel;
        } else {
            [_unit,"Argh... I've told you, I have no idea where he is... Leave me alone ! Please !", false] spawn fnc_talk; 
            [_unit,-10] remoteExec ["fnc_updateRep",2];
            _unit removeAction _action; 
            removeAllActions _unit;
        };
        _this call fnc_endTalking;
    },nil,1,true,true,"","true",20,false,""];
};


fnc_startTalking = {
    params["_unit","_talker","_action"];
    if (_unit getVariable["DCW_talking",false]) exitWith {hint "You can't do multiple action at the same time...";false;};
    _unit setVariable["DCW_talking",true];
    _unit setFormDir ([_unit,_talker] call BIS_fnc_dirTo);
    _unit setDir ([_unit,_talker] call BIS_fnc_dirTo);
    _talker doWatch _unit;
    _unit doWatch _talker;
    _unit lookAt _talker;
    true;
};


fnc_endTalking = {
    params["_unit","_talker","_action"];
    _unit setVariable["DCW_talking",false];
    true;
};