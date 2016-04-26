/*
	Author: Aaron Clark - EpochMod.com

    Contributors: Andrew Gregory

	Description:
	Player death handler

    Licence:
    Arma Public License Share Alike (APL-SA) - https://www.bistudio.com/community/licenses/arma-public-license-share-alike

    Github:
    https://github.com/EpochModTeam/Epoch/tree/master/Sources/epoch_code/compile/functions/EPOCH_fnc_playerDeath.sqf

    Example:
    player addEventHandler ["Killed", {_this call EPOCH_fnc_playerDeath}];

    Parameter(s):
		_this select 0: OBJECT - player
		_this select 1: OBJECT - killer

	Returns:
	BOOL
*/
private _tapDiag = "TapOut";
private _doRevenge = false;
params ["_unit", "_killer"];

// test ejecting unit from vehicle if dead client side
if (vehicle _unit != _unit) then {
	_unit action["Eject", vehicle _unit];
};

[player,_killer,toArray profileName,Epoch_personalToken] remoteExec ["EPOCH_server_deadPlayer",2];

// disable build mode
EPOCH_buildMode = 0;
EPOCH_snapDirection = 0;
EPOCH_Target = objNull;

if(player != _killer && (isPlayer _killer || isPlayer (effectiveCommander _killer)))then{_tapDiag = "TapOut2";};//TODO: vehicle check may not always be reliable

if (Epoch_canBeRevived) then {
	setPlayerRespawnTime 600;
	createDialog _tapDiag;
} else {
	setPlayerRespawnTime 15;
	["<t size='1.6' color='#99ffffff'>You can be just revived once per life!</t>", 5] call Epoch_dynamicText;
};

[_killer, _tapDiag] spawn{
	_killer2 = _this select 0;
	_tapDiag2 = _this select 1;
	while {!alive player} do {

		if (playerRespawnTime <= 1) exitWith{ (findDisplay 46) closeDisplay 0; };
		if (playerRespawnTime > 15 && !dialog) then {createDialog _tapDiag2;};
		if (isObjectHidden player) then {closeDialog 2;};
		if(player getVariable["EPOCH_doBoom",false])exitWith{player setVariable ["EPOCH_doBoom",nil];[player] call EPOCH_fnc_playerDeathDetonate;};
		if(player getVariable["EPOCH_doMorph",false])exitWith{player setVariable ["EPOCH_doMorph",nil];[selectRandom (getArray (getMissionConfig "CfgEpochClient" >> "deathMorphClass")),player,_killer2] call EPOCH_fnc_playerDeathMorph;};
		uiSleep 0.1;
	};
};