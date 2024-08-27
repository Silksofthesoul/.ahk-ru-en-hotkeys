#SingleInstance

Loop {
  Sleep, 300
  WinGet, NewHWND, ID, A
  if (no_detect_window <> -1) and (LastHWND = NewHWND) {
    Continue
  } else {
    LastHWND = %NewHWND%
    WinGet, NewPID, PID, A
    if(LastPID = NewPID) {
      Continue
    } else {
      LastPID = %NewPID%
      new_layout := check_en_ru()
      if(new_layout = "RU") {
        ;sound_RU()
      } else if(new_layout = "EN") {
        ;sound_EN()
      }
      Sleep, 300
    }
  }
}

sound_RU() {
  ;SoundBeep, 200, 30 
}

sound_EN() {
  ;SoundBeep, 5000, 30 
}

kdb_msg(text) {
  no_detect_window := -1
  ToolTip, %text%, A_CaretX + 10, A_CaretY - 20
  SetTimer, KdbRemoveToolTip, -1000
  return

  KdbRemoveToolTip:
  ToolTip
  no_detect_window := 1
  return
}

check_en_ru_by_window_id(WinID) {
  SetFormat, Integer, H
  Locale_En := 0x4090409 ; EN (USA)
  Locale_Ru := 0x4190419 ; RU
  ThredID := DllCall("GetWindowThreadProcessId", "Int", WinID, "Int", "0")
  InputLocaleID := DllCall("GetKeyboardLayout", "Int", ThreadID)

  if(store_layout <> InputLocaleID) {
    if(InputLocaleID = Locale_En) {
      Menu tray, icon, %A_ScriptDir%\__2.ico
    } else if(InputLocaleID = Locale_Ru) {
      Menu tray, icon, %A_ScriptDir%\__2.ico
    } else {
      Menu tray, icon, %A_ScriptDir%\__2.ico
    }
  }

  store_layout = InputLocaleID
  if(InputLocaleID = Locale_En) {
    return "EN"
  } else if(InputLocaleID = Locale_Ru) {
    return "RU"
  } else {
    return "??"
  }
}

check_en_ru() {
  SetFormat, Integer, H
  WinGet, WinId,, A
  return check_en_ru_by_window_id(WinID)
}

switch_en_ru(set_layout) {
  old_layout := check_en_ru()

  if(old_layout = set_layout) {
    kdb_msg(set_layout)
    EXIT
  }

  if(old_layout = "RU") {
    set_layout := "ENG"
  } else {
    set_layout := "RU"
  }

  if(set_layout = "RU") {
    SendMessage, 0x50,, % Locale_Ru,, A
    sound_RU()
  } else if(set_layout = "ENG") {
    SendMessage, 0x50,, % Locale_En,, A
    sound_EN()
  }

  new_layout := check_en_ru()
  kdb_msg(new_layout)
}


kdb_en() {
  PostMessage, 0x50, 0, 0x4090409,, A
  kdb_msg("ENG")
}

kdb_ru() {
  PostMessage, 0x50, 0, 0x4190419,, A
  kdb_msg("RU")
}
;// Ctr+alt+1 - en
;// Ctr+alt+2 - ru
^!1:: kdb_en()
^!2:: kdb_ru()
