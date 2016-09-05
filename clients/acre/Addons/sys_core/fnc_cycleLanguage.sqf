//fnc_cycleLanguage.sqf
#include "script_component.hpp"

if((count ACRE_SPOKEN_LANGUAGES) > 1) then {
	private _nextId = (ACRE_SPOKEN_LANGUAGES find ACRE_CURRENT_LANGUAGE_ID) + 1;
	if(_nextId > (count ACRE_SPOKEN_LANGUAGES)-1) then {
		_nextId = 0;
	};
	private _languageId = ACRE_SPOKEN_LANGUAGES select _nextId;
	private _language = GVAR(languages) select _languageId;
	_language params ["_languageKey","_languageName"];
	[_languageKey] call FUNC(setSpeakingLanguage);
	[_languageName,"Now speaking","",1] call EFUNC(sys_list,displayHint);
	[] call FUNC(updateSelf);
	if(ACRE_LOCAL_SPEAKING) then {
		//@TODO: This is an uber hack, should probably be set up as a TS event.
		//Basically we update globally a locally set object variable from the
		//start speaking event when they cycle languages while talking.
		acre_player setVariable [QUOTE(GVAR(languageId)), _languageId, true];
	};
} else {
	if((count ACRE_SPOKEN_LANGUAGES) == 1) then {
		private _languageId = ACRE_SPOKEN_LANGUAGES select 0;
		private _language = GVAR(languages) select _languageId;
		_language params ["_languageKey","_languageName"];
		[_languageName,"Now speaking","",1] call EFUNC(sys_list,displayHint);
	} else {
		["No Babel Active","","",1] call EFUNC(sys_list,displayHint);
	};
};

false
