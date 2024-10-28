#Include Gdip.ahk 
#IfWinActive Path of Exile
#SingleInstance force
#NoEnv  
; #Warn
#Persistent 
#MaxThreadsPerHotkey 3

SetTitleMatchMode 3
SendMode Input  
CoordMode, Mouse, Client
SetWorkingDir %A_ScriptDir%  
Thread, interrupt, 0
SetBatchLines, -1

OnExit, Cleanup

; Initialize GDI+ for drawing
pToken := Gdip_Startup()
OnExit, Cleanup


I_Icon = PoeC.ico
IfExist, %I_Icon%
  Menu, Tray, Icon, %I_Icon%

;General
; Dont change the speed & the tick unless you know what you are doing
global Speed=1
global Tick=250

;Coordinates
global GuiX=5
global GuiY=1005

global CurencySpam=False
global TrigerColor=0x73AFE6
global convertedToRgb=ConvertBGRtoRGB(TrigerColor)
global Px=0
global Py=0
global countV=0

; Area where search for success item is performed
global topLeftX := 379, topLeftY := 548
global bottomRightX := 502, bottomRightY := 779

; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

If FileExist("PoeAutoCraft.ini"){ 
	IniRead, %GuiX%, PoeAutoCraft.ini, Coordinates, GuiX
	IniRead, %GuiY%, PoeAutoCraft.ini, Coordinates, GuiY
	IniRead, %Speed%, PoeAutoCraft.ini, General, Speed
	IniRead, %TrigerColor%, PoeAutoCraft.ini, General, TrigerColor
 	
} else {
	IniWrite, %GuiX%, PoeAutoCraft.ini, Coordinates, GuiX
	IniWrite, %GuiY%, PoeAutoCraft.ini, Coordinates, GuiY
	IniWrite, %TrigerColor%, PoeAutoCraft.ini, General, TrigerColor
}


; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
; Gui (default bottom left)
; -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Gui, Color, 0X130F13
Gui +LastFound +AlwaysOnTop +ToolWindow
WinSet, TransColor, 0X130F13
Gui -Caption
Gui, Font, bold cFFFFFF S10, Trebuchet MS

; Gui for speed adjustments, placed above Auto-Craft field
Gui, Add, Text, x5 y800 h30 Center, Speed:  ; "Speed" label, centered and positioned lower
Gui, Add, Button, x+10 h30 gDecreaseSpeed, -  ; Decrease speed button
Gui, Add, Edit, vSpeedEdit x+5   h30 readonly Center, %Speed%  ; Speed input field
Gui, Add, Button, x+5 h30 gIncreaseSpeed, +  ; Increase speed button
Gui, Add, Button, x+10 h30 gSelectArea, Select Area  ; Select Area button, placed to the right of speed adjustment buttons

; Auto-Craft status and Current-Tries fields
Gui, Add, Text, x0 y+20 BackgroundTrans vT1, Auto-Craft: OFF  ; "Auto-Craft" field, positioned lower
Gui, Add, Text, y+0.5 BackgroundTrans vT2, Current-Tries: 0  ; "Current-Tries" field

; Color Picker Button
Gui, Add, Button, x0 y+10 h30 gPickColor vPickColorButton BackgroundFFFFFF Center, Pick Color
Gui, Add, Text, +c%convertedToRgb% x+5 vColorDisplay h40 w90 Center, Selected Color: Default

; Create a full-screen transparent GUI for drawing
Gui, +AlwaysOnTop +ToolWindow -Caption +E0x80000 ; E0x80000 = WS_EX_LAYERED (transparent background)
Gui, Show, w%A_ScreenWidth% h%A_ScreenHeight%, SelectionOverlay ; Full screen transparent overlay

hwnd := WinExist("A")
hbm := CreateDIBSection(A_ScreenWidth, A_ScreenHeight)
hdc := CreateCompatibleDC()
obm := SelectObject(hdc, hbm)
pGraphics := Gdip_GraphicsFromHDc(hdc)
Gdip_SetSmoothingMode(pGraphics, 4)

; Set the GUI to be initially transparent
UpdateLayeredWindow(hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
return

DecreaseSpeed:
    Speed > 1.2 ? Speed-=0.2 : Speed:=1
    GuiControl,, SpeedEdit, %Speed%
return

IncreaseSpeed:
    Speed < 3.5 ? Speed+=0.2 : Speed:=Speed
    GuiControl,, SpeedEdit, %Speed%
return


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
	BlockInput, On
	CurencySpam := True
	countV := 0
	GuiUpdate()
	CoordMode, Pixel, Screen
	Send {Shift down}
	Loop{
		GuiUpdateCounter()
	    PixelSearch, Px, Py,topLeftX, topLeftY, bottomRightX, bottomRightY, TrigerColor, 20, Fast
		Sleep, 50
		ToolTip, % (ErrorLevel = 0) ? "Success" : "Failure"
		if (ErrorLevel = 0) {
			SoundPlay, %A_ScriptDir%\audio\gay-echo.mp3
			break
		}
		if (GetKeyState("K", "P") and GetKeyState("Alt", "P")){
			break
		}
		Click
		RandomSleep(500,700)
	}
	Send {Shift up}
	BlockInput, Off
	CurencySpam := False
	GuiUpdate()
	return

RandomSleep(min,max){
	Random, r, %min%, %max%
	r:=floor(r/Speed)
	Sleep %r%
	return
}


^!O:: CheckColorInArea()
^!I:: CheckColorInCursor()

; Check cursor cords
CheckColorInCursor(){
	MouseGetPos, xpos, ypos
	PixelGetColor, xycolor , xpos, ypos
    msgbox, X=%xpos% Y=%ypos% XYColor=%xycolor%
	return
}

;Control +Alt+O hotkey to check for color in area
CheckColorInArea(){	
	CoordMode, Pixel, Screen
	PixelSearch, Px, Py, topLeftX, topLeftY, bottomRightX, bottomRightY, TrigerColor, 3, Fast
    Sleep, 80
	if (ErrorLevel = 0){
    	Tooltip, 'Found x=' %Px% 'y=' %Py%
	}
    Tooltip, 'Not found'
	return
}

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


SelectArea:
    Tooltip, Click and drag to select an area
    ; Wait for the user to start dragging with the left mouse button
    Loop
    {
        Sleep, 10
        if (GetKeyState("LButton", "P"))
        {
            MouseGetPos, topLeftX, topLeftY
            break
        }
    }

    ; Draw the rectangle dynamically while dragging
    Loop
    {
        Sleep, 10
        if !GetKeyState("LButton", "P")
            break

        MouseGetPos, x, y

        ; Calculate rectangle dimensions
        width := abs(x - topLeftX)
        height := abs(y - topLeftY)

        ; Determine the top-left corner
        topLeftX_Draw := (x < topLeftX) ? x : topLeftX
        topLeftY_Draw := (y < topLeftY) ? y : topLeftY

        ; Clear previous drawing
        Gdip_GraphicsClear(pGraphics)

        ; Create a semi-transparent brush
        pBrush := Gdip_BrushCreateSolid(0x8000FF00) ; ARGB format: 50% alpha (semi-transparent), green color

        ; Draw the rectangle
        Gdip_FillRectangle(pGraphics, pBrush, topLeftX_Draw, topLeftY_Draw, width, height)
        
        ; Display the updated image in the GUI
        UpdateLayeredWindow(hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight, 100)
        
        ; Delete the brush to avoid memory leaks
        Gdip_DeleteBrush(pBrush)
    }

    ; Update the final rectangle coordinates
    MouseGetPos, bottomRightX, bottomRightY

    ; Display the selected area coordinates in a tooltip
    Tooltip, Selected Area: %topLeftX% - %topLeftY% to %bottomRightX% - %bottomRightY%

    ; Clear the drawing after selection is complete
    Gdip_GraphicsClear(pGraphics)
    UpdateLayeredWindow(hwnd, hdc, 0, 0, A_ScreenWidth, A_ScreenHeight)
return


; -------------------------------------------------------------------------------------------------------------------
; Button Click Handler - Pick Color
; -------------------------------------------------------------------------------------------------------------------
PickColor:
	CoordMode, Pixel, Screen
    ToolTip, Please click anywhere on the screen to pick a color.
    
    SetTimer, ShowColorUnderMouse, 50
    ; Wait for the user to click
    KeyWait, LButton, D
    SetTimer, ShowColorUnderMouse, Off
    ToolTip
      ; Get mouse position and pixel color
    MouseGetPos, mouseX, mouseY
    PixelGetColor, pickedColor, %mouseX%, %mouseY%
    
    ; Convert color to hex format
    pickedColorHex := Format("{:02X}{:02X}{:02X}", (pickedColor >> 16) & 0xFF, (pickedColor >> 8) & 0xFF, pickedColor & 0xFF)
    
    ; Update GUI to display the picked color
    TrigerColor:=pickedColor
    convertedToRgb:=ConvertBGRtoRGB(TrigerColor)
    GuiControl, +C%convertedToRgb%, PickColorButton  ; Simulate button color change by changing Text background
    GuiControl,, ColorDisplay, Selected Color: %convertedToRgb%
    GuiControl, +c%convertedToRgb%, ColorDisplay  ; Change the text color of "Selected Color"
return

ShowColorUnderMouse:
    ; Get the current mouse position
    MouseGetPos, mouseX, mouseY

    ; Get the color at the current mouse position in RGB format
    PixelGetColor, color, %mouseX%, %mouseY% RGB

    ; Convert RGB to hexadecimal format (e.g., 0xFFFFFF)
    colorHex := Format("{:06X}", color)

    ; Display the color in the tooltip along with cursor position
    ToolTip, Current Color: #%colorHex%`nX: %mouseX% Y: %mouseY%
    GuiControl, +c%color%, ColorDisplay  ; Change the text color of "Selected Color"
Return

ConvertBGRtoRGB(bgrColor) {
    blue := (bgrColor >> 16) & 0xFF
    green := (bgrColor >> 8) & 0xFF
    red := bgrColor & 0xFF
    rgbColor := (red << 16) | (green << 8) | blue
    return rgbColor
}

Cleanup:
    Gdip_DeleteGraphics(pGraphics)
    SelectObject(hdc, obm)
    DeleteObject(hbm)
    DeleteDC(hdc)
    Gdip_Shutdown(pToken)
    ExitApp
return