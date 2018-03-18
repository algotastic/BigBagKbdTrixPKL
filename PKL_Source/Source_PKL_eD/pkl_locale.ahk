; eD: Added Trim() around any 'SubStr( A_LoopField, 1, pos-1 )' entries (from vVv, AHK v1.1 so I use my own for now)
; eD TODO: Better iniReadSection() for the below, able to parse into a pdic (AHK v1.1).

pkl_locale_load( lang, compact = 0 )
{
	; eD: Read/set default locale string list
	static defLocStrInit	; eD: Ensure the defaults are initialized only once (as this function is run on layout change too)
	if ( defLocStrInit != -1 )
	{
		Loop, 22
		{
			str := pklIniRead( "LocStr" . SubStr( "00" . A_Index, -1 ), "", "Pkl_Dic", "DefaultLocaleStr" ) ; eD: Pad with zero if index < 10
			str := strEsc( str )
			setPklInfo( "LocStr_" . A_Index , str )
;			teststr := teststr . "`n" . A_Index . "  " . str
		}
		defLocStrInit := -1
	}

	if ( compact )
		file = %lang%.ini
	else
		file = Languages\%lang%.ini

	setPklInfo( "LocStr_RefreshMenu", pklIniRead( "refreshMenuText", "Refresh"       , "Pkl_eD_", "pkl"  ) )
	setPklInfo( "LocStr_KeyHistMenu", pklIniRead( "keyhistMenuText", "Key history...", "Pkl_eD_", "pkl"  ) )
	
	line := iniReadSection( file, "pkl" )
	Loop, parse, line, `r`n
	{
	/*
		pos := InStr( A_LoopField, "=" )
		key := Trim( SubStr( A_LoopField, 1, pos-1 ))
		val := strEsc( SubStr( A_LoopField, pos+1 ))
	*/
		pklIniKeyVal( A_Loopfield, key, val )	; eD: A more compact way (but still in a loop)
		if ( val != "" )
			setPklInfo( "LocStr_" . key , val )		; pklLocaleStrings( key, val, 1 )
	}

	line := iniReadSection( file, "SendU" )
	Loop, parse, line, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val )
		SendU_SetLocaleTxt( key, val )
	}

	line := iniReadSection( file, "detectDeadKeys" )
	Loop, parse, line, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val )
		detectDeadKeys_SetLocaleTxt( key, val )
	}
	
	line := iniReadSection( file, "keyNames" )
	Loop, parse, line, `r`n
	{
		pklIniKeyVal( A_Loopfield, key, val, 0 )
		setHotkeyText( key, val )
	}
}

setHotkeyText( hk, localehk )
{
	getHotkeyText( hk, localehk, 1 )
}

getHotkeyText( hk, localehk = "", set = 0 )
{
	static localizedHotkeys := ""
	static pdic := 0
	if ( pdic == 0 )
	{
		pdic := HashTable_New()
	}
	if ( set == 1 ) {
		HashTable_Set( pdic, hk, localehk )
		localizedHotkeys .= " " . hk
	} else {
		if ( hk == "all" )
			return localizedHotkeys
		return HashTable_Get( pdic, hk )
	}
}

getReadableHotkeyString( str )
{
	StringReplace, str, str, <^>!, AltGr &%A_Space%, 1
	StringReplace, str, str, SC029, Tilde, 1
	
	StringReplace, str, str, <+, LShift &%A_Space%, 1
	StringReplace, str, str, <^, LCtrl &%A_Space%, 1
	StringReplace, str, str, <!, LAlt &%A_Space%, 1
	StringReplace, str, str, <#, LWin &%A_Space%, 1

	StringReplace, str, str, >+, RShift &%A_Space%, 1
	StringReplace, str, str, >^, RCtrl &%A_Space%, 1
	StringReplace, str, str, >!, RAlt &%A_Space%, 1
	StringReplace, str, str, >#, RWin &%A_Space%, 1
	
	StringReplace, str, str, +, Shift &%A_Space%, 1
	StringReplace, str, str, ^, Ctrl &%A_Space%, 1
	StringReplace, str, str, !, Alt &%A_Space%, 1
	StringReplace, str, str, #, Win &%A_Space%, 1
	
	StringReplace, str, str, *,, 1
	StringReplace, str, str, $,, 1
	StringReplace, str, str, ~,, 1

	str := RegExReplace( str, "(\w+)", "#[$1]" )
	hotkeys := getHotkeyText( "all" )
	Loop, Parse, hotkeys, %A_Space%
	{
		lhk := getHotkeyText( A_LoopField )
		StringReplace, str, str, #[%A_LoopField%], %lhk%, 1
	}
	str := RegExReplace( str, "#\[(\w+)\]", "$1" )
	
	; eD: Moved the shorter key names down so they'll work on the Languages file.
	StringReplace, str, str, Return, Enter, 1
	StringReplace, str, str, Escape, Esc, 1
	StringReplace, str, str, BackSpace, Back, 1
	StringReplace, str, str, Backspace, Back, 1
	StringReplace, str, str, Delete, Del, 1
	StringReplace, str, str, Insert, Ins, 1
	StringReplace, str, str, Control, Ctrl, 1
	
	return str
}
