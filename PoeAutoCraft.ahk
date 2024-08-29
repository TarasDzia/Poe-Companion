; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Copyright (c) 2017, Nidark
; All rights reserved.
;
; Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
;   * Partial or integral redistributions of source code in any form (code/binary) cannot be sold, but only provided free of any charge.
;   * Partial or integral redistributions of source code in any form (code/binary) must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
;   * The name of the contributors may not be used to endorse or promote products derived from this software without specific prior written permission.
;
; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; The most updated version is always here: https://github.com/nidark/Poe-Companion
; Support: https://discord.gg/qfDkyTs
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; If you need to make changes, DONT change the variables from the script! 
; Change them in the PoeCompanion.INI file!
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Most of the functions will work without any INI changes for windowed full-screen 1920x1080 Steam Edition DX11, having the wisdom & portal scrolls respectively on the last 2 positions of the first row. 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; The SwichGem function & Auto-flask will work only if you have the same setup like me.   
; But most probably you will need to adjust those positions & flask logic in INI using "ALT+O", as this is mostly character & skill-key based.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; For different setups (resolutions and/or scroll positions) you need to use the "ALT+O" function and change the coordonates in the INI file.
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

#IfWinActive Path of Exile
#SingleInstance force
#NoEnv  
#Warn  
#Persistent 
#MaxThreadsPerHotkey 3

SetTitleMatchMode 3
SendMode Input  
CoordMode, Mouse, Client
SetWorkingDir %A_ScriptDir%  
Thread, interrupt, 0

I_Icon = PoeC.ico
IfExist, %I_Icon%
  Menu, Tray, Icon, %I_Icon%

;General
; Dont change the speed & the tick unless you know what you are doing
global Speed=1
global Tick=250

;Coordinates
global GuiX=-5
global GuiY=1005

;ItemSwap
global CurrentGemX=1483
global CurrentGemY=372
global AlternateGemX=1379 
global AlternateGemY=171
global AlternateGemOnSecondarySlot=1

;AutoPot Setup
global ChatColor=0x0E6DBF
global ChatX1=10
global ChatY1=875
global ChatX2=24
global ChatY2=890


global CurencySpam=False
global exitLoop := False
global Px=0
global Py=0
global countV=0
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

If FileExist("PoeAutoCraft.ini"){ 
	IniWrite, %GuiX%, PoeCompanion.ini, Coordinates, GuiX
	IniWrite, %GuiY%, PoeCompanion.ini, Coordinates, GuiY
 	
} else {
	IniWrite, %GuiX%, PoeCompanion.ini, Coordinates, GuiX
	IniWrite, %GuiY%, PoeCompanion.ini, Coordinates, GuiY
}
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Gui (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Gui, Color, 0X130F13
Gui +LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, 0X130F13
Gui -Caption
Gui, Font, bold cFFFFFF S10, Trebuchet MS
Gui, Add, Text, y+0.5 BackgroundTrans vT1, Auto-Craft: OFF
Gui, Add, Text, y+0.5 BackgroundTrans vT2, Current-Tries: 0 
Gui, Show, x%GuiX% y%GuiY%
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; KEY Binding
; Legend:   ! = Alt      ^ = Ctrl     + = Shift 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
$!F1::ExitApp  ; Alt+F1: Exit the script
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; The following macros are NOT ALLOWED by GGG (EULA), as we send multiple server actions with one button pressed
; This can't be identified as we randomize all timmings, but dont use it if you want to stick with the EULA 
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

!+J::
	CurencySpam := True
	countV := 0
	GuiUpdate()
	Send {ShiftDown} 
	CoordMode, Pixel, Screen
	Loop{
		GuiUpdateCounter()
		PixelSearch, Px, Py, 379, 548, 502, 779, 0x77B4E7, 3, Fast
		Sleep, 50
		ToolTip, ErrorLevel: %ErrorLevel%  Px: %Px%  Py: %Py%
		if (ErrorLevel = 0) {
			break
		}
		if (GetKeyState("K", "P") and GetKeyState("Alt", "P")){
			break
		}
		Click
		RandomSleep(500,1000)
	}
	Send {ShiftUp} 
	CurencySpam := False
	GuiUpdate()
	return

RandomSleep(min,max){
	Random, r, %min%, %max%
	r:=floor(r/Speed)
	Sleep %r%
	return
}

; ^!z::  ; Control+Alt+Z hotkey to check for color in cursor cords
; MouseGetPos, MouseX, MouseY
; PixelGetColor, color, %MouseX%, %MouseY%
; ToolTip, Color: %color% coordinates: %MouseX% , %MouseY%
; return

; ^!z:: ; Control+Alt+Z hotkey to check cursor cords
;     MouseGetPos, xpos, ypos
; 	PixelGetColor, xycolor , xpos, ypos
;     msgbox, X=%xpos% Y=%ypos% XYColor=%xycolor%
; 	return

; $!O:: Alt+O hotkey to check for color in area
; 	CoordMode, Pixel, Screen
; 	PixelSearch, Px, Py, 379, 548, 502, 779, 0x77B4E7, 3, Fast
; 	if (ErrorLevel = 0){
; 		msgbox, 'Found x=' %Px% 'y=' %Py%
; 	}
;     msgbox, %ErrorLevel%
; 	return

GuiUpdate(){
	if (CurencySpam = True) {
		CurencySpamToggle:="ON" 
	}else CurencySpamToggle:="OFF" 
	
	GuiControl ,, T1, Auto-Craft: %CurencySpamToggle%
	Return
}

GuiUpdateCounter(){
	Critical  
    countV++
	GuiControl, MoveDraw, T2, w150
    GuiControl ,, T2, Current-tries: %countV%
    Gui, Show, AutoSize
    return
}
