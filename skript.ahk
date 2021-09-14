; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; --------- Author: Jonas Weis (größtenteils) -----------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------


; -----------------------------------
; --  Inhaltsverzeichnis  -----------
; -----------------------------------
; 1. AutoReload des Skriptes beim Speichern
; 2. Den virtuellen Desktop mit Windows+Nummer wechseln. Dann kann man deutlich leichter mit mehreren Desktops arbeiten
; 3. Mit STRG+ALT+T für das oberste Fenster AlwaysOnTop toggeln, sprich man kann z.B. den Editor auf kleiner Größe immer im Vordergrund halten
; 4. Den markierten Text in Google suchen mit STRG+SHIFT+C
; 5. Autohotkey deaktivieren mit STRG+ALT+A
; 6. Öffnet Input-Box zur google-suche
; 7. Übersetze markierten Text nach Englisch (STRG+SHIFT+E) oder nach Deutsch (STRG+SHIFT+D)
; 8. Übersicht aller Hotkeys mit STRG+ALT+M
; 9. Öffnet PowerShell aus dem Explorer im aktuellen Pfad mit ALT+C
; 10. Öffnet das kleine Optionsmenü (wie beim Rechtsklick) in Word durch ALT+Enter
; 11. "Hotstrings" bzw. Autovervollständigungen und Shortcuts
; 12. Wichtigste Tasten und Befehle


; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; AutoReload des Skriptes beim Speichern
#Persistent
#SingleInstance force
SetTimer,UPDATEDSCRIPT,500
 UPDATEDSCRIPT:

FileGetAttrib,attribs,%A_ScriptFullPath%

            IfInString,attribs,A
             {
                FileSetAttrib,-A,%A_ScriptFullPath%

                SplashTextOn,,,Updated script

                Sleep,500
                SplashTextOff 
                Reload             
}



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
;  Den virtuellen Desktop mit Windows+Nummer wechseln. Dann kann man deutlich leichter mit mehreren Desktops arbeiten (Bsp: Win+2 oder Win+3)

DesktopCount = 2
CurrentDesktop = 1

mapDesktopsFromRegistry() {
 global CurrentDesktop, DesktopCount
 
 IdLength := 32
 SessionId := getSessionId()
 if (SessionId) {
 RegRead, CurrentDesktopId, HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\SessionInfo\%SessionId%\VirtualDesktops, CurrentVirtualDesktop
 if (CurrentDesktopId) {
 IdLength := StrLen(CurrentDesktopId)
 }
 }
 
 RegRead, DesktopList, HKEY_CURRENT_USER, SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VirtualDesktops, VirtualDesktopIDs
 if (DesktopList) {
 DesktopListLength := StrLen(DesktopList)
 
 DesktopCount := DesktopListLength / IdLength
 }
 else {
 DesktopCount := 1
 }
 
 i := 0
 while (CurrentDesktopId and i < DesktopCount) {
 StartPos := (i * IdLength) + 1
 DesktopIter := SubStr(DesktopList, StartPos, IdLength)
 OutputDebug, The iterator is pointing at %DesktopIter% and count is %i%.
 
 if (DesktopIter = CurrentDesktopId) {
 CurrentDesktop := i + 1
 OutputDebug, Current desktop number is %CurrentDesktop% with an ID of %DesktopIter%.
 break
 }
 i++
 }
}

getSessionId()
{
 ProcessId := DllCall("GetCurrentProcessId", "UInt")
 if ErrorLevel {
 OutputDebug, Error getting current process id: %ErrorLevel%
 return
 }
 OutputDebug, Current Process Id: %ProcessId%
 DllCall("ProcessIdToSessionId", "UInt", ProcessId, "UInt*", SessionId)
 if ErrorLevel {
 OutputDebug, Error getting session id: %ErrorLevel%
 return
 }
 OutputDebug, Current Session Id: %SessionId%
 return SessionId
}

switchDesktopByNumber(targetDesktop)
{
 global CurrentDesktop, DesktopCount
 
 mapDesktopsFromRegistry()
 
 if (targetDesktop > DesktopCount || targetDesktop < 1) {
 OutputDebug, [invalid] target: %targetDesktop% current: %CurrentDesktop%
 return
 }
 
 while(CurrentDesktop < targetDesktop) {
 Send ^#{Right}
 CurrentDesktop++
 OutputDebug, [right] target: %targetDesktop% current: %CurrentDesktop%
 }
 
 while(CurrentDesktop > targetDesktop) {
 Send ^#{Left}
 CurrentDesktop--
 OutputDebug, [left] target: %targetDesktop% current: %CurrentDesktop%
 }
}

createVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^d
 DesktopCount++
 CurrentDesktop = %DesktopCount%
 OutputDebug, [create] desktops: %DesktopCount% current: %CurrentDesktop%
}

deleteVirtualDesktop()
{
 global CurrentDesktop, DesktopCount
 Send, #^{F4}
 DesktopCount--
 CurrentDesktop--
 OutputDebug, [delete] desktops: %DesktopCount% current: %CurrentDesktop%
}

SetKeyDelay, 75
mapDesktopsFromRegistry()
OutputDebug, [loading] desktops: %DesktopCount% current: %CurrentDesktop%

LWin & 1::switchDesktopByNumber(1)
LWin & 2::switchDesktopByNumber(2)
LWin & 3::switchDesktopByNumber(3)
LWin & 4::switchDesktopByNumber(4)
LWin & 5::switchDesktopByNumber(5)
LWin & 6::switchDesktopByNumber(6)
LWin & 7::switchDesktopByNumber(7)
LWin & 8::switchDesktopByNumber(8)
LWin & 9::switchDesktopByNumber(9)



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Toggle Window always on Top mit STRG+ALT+T 
^!t::
WinSet, AlwaysOnTop, Toggle, A
return



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Sucht momentan markierten Text in Google
^+c::
{
 Send, ^c
 Sleep 50
 Run, http://www.google.com/search?q=%clipboard%
 Return
}



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Deaktiviert AutoHotKey mit STRG+ALT+A
^!a::Suspend
return
; Manuelles reaktivieren benötigt



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; InputBox for Google-Suche mit STRG+ALT+G
^!g::
InputBox, UserInput, Google-Suche, , , 200, 100
if ErrorLevel
{}
else
{
    Run, https://www.google.com/search?q=%UserInput%
}
return



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Übersteze markierten Text (egal welche Sprache)
; Ins Deutsche STRG+SHIFT+D
^+d::
 Send, ^c
 Sleep 50
 Run, https://translate.google.de/?sl=auto&tl=de&text=%Clipboard%
return

; Ins Englische STRG+SHIFT+E
^+e::
 Send, ^c
 Sleep 50
 Run, https://translate.google.de/?sl=auto&tl=en&text=%Clipboard%
return



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Übersicht aller Hotkeys

^!m::
If(WinExist("Overview"))
{
   WinClose, Overview
}
Else
{
   Gui, New, , Overview
   Gui, Add, Text,, Übersicht aller Hotkeys
   Gui, Add, Text,, STRG + ALT + T 	|	AlwaysOnTop toggeln
   Gui, Add, Text,, STRG + Shift + C 	| 	Markiertes in Google suchen 
   Gui, Add, Text,, Windows + Nummer 	| 	Virtuellen Desktop wechseln
   Gui, Add, Text,, STRG + ALT + P 	| 	Passwort-Einfüger
   Gui, Add, Text,, WIN + ENTF  		| 	Papierkorb leeren
   Gui, Add, Text,, STRG + ALT + A  	| 	Autohotkey deaktivieren
   Gui, Add, Text,, STRG + ALT + G 	| 	InputBox zur Google Suche
   Gui, Add, Text,, STRG + SHIFT + T 	| 	Restzeit bis zur Pause
   Gui, Add, Text,, STRG + SHIFT + P	| 	Erinnerungen ans Trinken starten
   Gui, Add, Text,, STRG + SHIFT + E	|	Übersetze ins Englische
   Gui, Add, Text,, STRG + SHIFT + D	|	Übersetze ins Deutsche
   Gui, Add, Text,, STRG + ALT+ M	|	Übersicht der Hotkeys
   Gui, Add, Text,, ALT + C   |	Öffnet Powershell vom aktuellen Pfad
   Gui, Add, Text,, ALT + Enter  |	Simuliert Rechtsklick in Word
   Gui, Add, Text,, 
   Gui, Add, Text,, Übersicht aller Hotstrings
   Gui, Add, Text,, @g -> jonas_weis@arburg.com
   Gui, Add, Text,, @d -> i20035@hb.dhbw-stuttgart.de
   Gui, Add, Text,, @s -> schul352
   Gui, Add, Text,, @m -> 2758638
   Gui, Add, Text,, cdsch -> cd C:\Users\schul352
   Gui, Add, Text,, cdente -> cd C:\Users\entep04
   Gui, Add, Text,, cdreact -> cd C:\Users\entep04\Desktop\homepage-react
   Gui, Add, Text,, cd- -> cd ..\
   Gui, Add, Text,, npmrs -> npm run start  
   Gui, Add, Text,,  @ba -> D:\BACKUP\CMD\shutdown_mode.txt`n         -> Datei für Daily Routine
   Gui, Show
}

return

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Öffnet PowerShell aus dem Explorer im aktuellen Pfad mit ALT+C
!c::
   WinGet, windowName, ProcessName, A
   if(windowName == "Explorer.EXE")
   {
      Send !ds{Enter}
   }
return



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Öffnet das kleine Optionsmenü (wie beim Rechtsklick) in Word durch ALT+Enter (vgl. IntelliJ)
!Enter::
   WinGet, windowName, ProcessName, A
   if(windowName == "WINWORD.EXE")
   {
      Send +{F10}
   }
return

; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Abkürzungen: Wenn das zwischen den Doppelpunkten geschrieben wird, wird es durch das dahinter ersetzt.
; Gilt nur wenn es allein steht, a@g würde zum Beispiel nicht ersetzt werden, ohne das a jedoch schon. 
::@g::jonas_weis@arburg.com
::@d::i20035@hb.dhbw-stuttgart.de
::@s::schul352
::@mat::2758638
::@mail::weis_jonas@mail.de
::cd-::cd ..\

; -------------------- Advanced Hotstrings ---------------------
:*:]d::        ; wenn die Klammer + d geschrieben werden, kommt folgendes dabei raus: "14.09.2021 13:48" 
FormatTime, CurrentDateTime,, dd.MM.yyyy HH:mm
SendInput %CurrentDateTime%
return

; Shortcuts
!^1::
Run, https://github.com/DHBW-Inf20/Anleitungen
return
!^2::
Run, notepad++.exe
return



; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; -------------------------------------------------------------------------------------------------------------------------------------------------------------------------
/* Tasten-Zuordnung:
Enter = {Enter}
Escape = {ESC}
Tab = {Tab}
Leertase = {Space}
Entfernen = {Del}
↑ = {Up}
← = {Left}
usw., siehe hier: https://ahkde.github.io/docs/commands/Send.htm
STRG = ^
Shift = +
Alt = !
Windows = #
*/

/* Wichtigste Befehle: 
Klassischer Aufbau: 
- Hotkey::Befehl (und return i.d.R.)
- ::abkürzung::DurchWasEsErsetztWerdenSoll

Send, Taste
Sleep, ZeitInMs
Run, ProgrammName
InputBox, AusgabeVar , Titel, Anzeigetext, HIDE, Breite, Höhe, X, Y, Locale, Zeitlimit, Standardwert
Nutzung von Variablen: %variable%
MsgBox, Text
WinGet, AusgabeVar , Unterbefehl, FensterTitel, FensterText, IgnoriereTitel, IgnoriereText
*/