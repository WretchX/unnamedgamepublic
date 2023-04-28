;CTRL+SHIFT+CLICK TO COLLAPSE/EXPAND ALL REGIONS

#Region Include
#include <ButtonConstants.au3>
#include <GUIConstantsEx.au3>
#include <GuiStatusBar.au3>
#include <WindowsConstants.au3>
#include <ProgressConstants.au3>
#include <StaticConstants.au3>
#include <ColorConstants.au3>
#include <Array.au3>
#include <FontConstants.au3>
#EndRegion Include

#Region Pre-GUI Globals
Global $testmode = True
Global $loopInterval = 0 ;sleep time for all While loops
Global $GameRunning = False ;if any minigame is currently active
Global $difficulty = 1 ;global difficulty. 1-5, or 6-$difficulty for inverse scaling
Global $score = 0 ;score used for all games
#EndRegion Pre-GUI Globals

#Region Pre-GUI Variables
#Region Title Variables
Global $titleMain = "Main Window" ;var name must match respective GUICreate var
Global $titleTest = "Test"
Global $titleButtonPop = "Button Pop"
Global $titleProgBar = "Progbar"
Global $titleSimonSays = "Simon Says"
#EndRegion Title Variables

#Region ProgBar Variables
Global $GIP_ProgBar = False ;Game In Progress
Global $progBarTop = 33
Global $progBarWidth = 10
Global $progBarHeight = 45
Global $timeInRange = 0
Global $left = 122
Global $right = 182
Global $failPercentLeft, $failPercentRight, $barFailLeft, $barFailRight, $BarProgress, _
		$ProgBar_FailPctLeft, $ProgBar_FailPctRight
#EndRegion ProgBar Variables

#Region ButtonPop Variables
Global $GIP_ButtonPop = False
Global $ButtonPopMax = 30
Global $TimeBetweenButtonSpawns = 700 ;!apply difficulty arithmetic
Global $DNT_ButtonPop = 0 ;Do Not Touch, needs to be 0
#EndRegion ButtonPop Variables

#Region SimonSays Variables
Global $GIP_SimonSays = False
Global $SScurrentLevel = 1
Global $SSclicks = 0
Global $animSpeed = 75 ;animation speed
Global $animDelay = $animSpeed*2
Global $arrSays, $numSays, $SSCorrectAnim
#EndRegion SimonSays Variables
#EndRegion Pre-GUI Variables

#Region Arrays
Global $arr_Games[10] = ["Main", "Test", "ProgBar", "ButtonPop", "SimonSays"]
GLobal $SScolor[9][3] = [["0x87CEEB", "0xABDDF1", "0xCFEBF7"], ["0x96FF7A", "0xB5FFA2", "0xD5FFCA"], ["0xFF9F2D", "0xFFBC6C", "0xFFD9AB"], _
						["0x937745", "0xBDA373", "0xD9CAAF"], ["0xFF6565", "0xFF9393", "0xFFC1C1"], ["0xB1B1B1", "0xC8C8C8", "0xE0E0E0"], _
						["0xFBFF80", "0xFCFFA6", "0xFEFFD8"], ["0x26B48A", "0x56DBB4", "0x9FEBD4"], ["0xFF97E0", "0xFFB6E9", "0xFFD5F3"]]
#EndRegion Arrays

#Region GUIs
#Region GUI Test Environment
If $testmode = True Then
	HotKeySet("{/}", "TestFunc")
	HotKeySet("{\}", "TestFunc2")
	HotKeySet("{HOME}", "Terminate")
	Global $test1, $test2
	$GUI_TEST = GUICreate($titleTest, 414, 357, 192, 124)
	$testlabel = GUICtrlCreateLabel("Test Mode", 110, 16, 200, 60)
	GUICtrlSetFont(-1, 20, 700)
	$testButton1 = GUICtrlCreateButton("Main Window", 64, 88, 129, 49)
	$testButton2 = GUICtrlCreateButton("Progress Bar", 208, 88, 129, 49)
	$testButton3 = GUICtrlCreateButton("Button Popup", 64, 144, 129, 49)
	$testButton4 = GUICtrlCreateButton("Simon Says", 208, 144, 129, 49)
	$testButton5 = GUICtrlCreateButton("5", 64, 200, 129, 49)
	$testButton6 = GUICtrlCreateButton("6", 208, 200, 129, 49)
	$testButton7 = GUICtrlCreateButton("7", 64, 256, 129, 49)
	$testButton8 = GUICtrlCreateButton("8", 208, 256, 129, 49)
	GUISetState(@SW_SHOW)
EndIf
#EndRegion GUI Test Environment

#Region GUI Main Window
$GUI_MAIN = GUICreate($titleMain, 587, 523, -1, -1)
$StatusBar1 = _GUICtrlStatusBar_Create($GUI_MAIN)
$butEvent1 = GUICtrlCreateButton("1", 32, 424, 81, 57)
$butEvent2 = GUICtrlCreateButton("2", 232, 416, 81, 57)
$butEvent3 = GUICtrlCreateButton("3", 448, 416, 81, 57)
$butEvent4 = GUICtrlCreateButton("4", 136, 312, 81, 57)
$butEvent5 = GUICtrlCreateButton("5", 344, 312, 81, 57)
$butEvent6 = GUICtrlCreateButton("6", 32, 216, 81, 57)
$butEvent7 = GUICtrlCreateButton("7", 240, 208, 81, 57)
$butEvent8 = GUICtrlCreateButton("8", 456, 208, 81, 57)
$butEvent9 = GUICtrlCreateButton("9", 104, 104, 81, 57)
$butEvent10 = GUICtrlCreateButton("10", 360, 104, 81, 57)
$butEvent11 = GUICtrlCreateButton("11", 216, 8, 137, 73)
If $testmode = False Then GUISetState(@SW_SHOW)
#EndRegion GUI Main Window

#Region GUI ProgBar Game
$GUI_PROGBAR = GUICreate($titleProgBar, 380, 300, -1, -1)
$Progress1 = GUICtrlCreateProgress(40, 49, 300, 25)
GUICtrlSetStyle($Progress1, $PBS_SMOOTH)
GUICtrlSetBkColor($Progress1, 0xFF0000)
GUICtrlSetColor($Progress1, 0xffffff)
$labInRange = GUICtrlCreateLabel("Time in range: ", 85, 16, 120, 30)
GUICtrlSetFont(-1, 12, 300)
$labRange = GUICtrlCreateLabel($timeInRange, 190, 16, 36, 17)
GUICtrlSetFont(-1, 12, 300)
$Label_Bar_Game = GUICtrlCreateLabel("Press SPACE", 120, 96, 73, 33)
$bStartBarGame = GUICtrlCreateButton("START", 120, 120, 100, 40)
GUISetState(@SW_HIDE)
#EndRegion GUI ProgBar Game

#Region GUI ButtonPop Game
$GUI_BUTTONPOP = GUICreate($titleButtonPop, 615, 437, -1, -1)
$LScore = GUICtrlCreateLabel($score, 10, 10, 40, 40)
$buttonx = 272
$buttony = 176
$ButtonStart = GUICtrlCreateButton("Start", $buttonx, $buttony, 73, 57)
GUISetState(@SW_HIDE)
#EndRegion GUI ButtonPop Game

#Region GUI SimonSays Game
$GUI_SIMONSAYS = GUICreate($titleSimonSays, 552, 490, -1, -1)
$SS_labLevel = GUICtrlCreateLabel("Level: " & $SScurrentLevel, 128, 32, 41, 17)
$SS_but1 = GUICtrlCreateButton("", 80, 112, 121, 105)
GUICtrlSetBkColor(-1, 0x87ceeb)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but2 = GUICtrlCreateButton("", 208, 112, 121, 105)
GUICtrlSetBkColor(-1, 0x96ff7a)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but3 = GUICtrlCreateButton("", 336, 112, 121, 105)
GUICtrlSetBkColor(-1, 0xff9f2d)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but4 = GUICtrlCreateButton("", 80, 224, 121, 105)
GUICtrlSetBkColor(-1, 0x937745)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but5 = GUICtrlCreateButton("", 208, 224, 121, 105)
GUICtrlSetBkColor(-1, 0xff6565)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but6 = GUICtrlCreateButton("", 336, 224, 121, 105)
GUICtrlSetBkColor(-1, 0xb1b1b1)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but7 = GUICtrlCreateButton("", 80, 336, 121, 105)
GUICtrlSetBkColor(-1, 0xfbff80)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but8 = GUICtrlCreateButton("", 208, 336, 121, 105)
GUICtrlSetBkColor(-1, 0x26b48a)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_but9 = GUICtrlCreateButton("", 336, 336, 121, 105)
GUICtrlSetBkColor(-1, 0xff97e0)
GUICtrlSetState(-1, $GUI_DISABLE)
$SS_butStart = GUICtrlCreateButton("Start Game", 176, 64, 177, 33)
$SS_butNextRound = GUICtrlCreateButton("Next Round", 176, 64, 177, 33)
GUICtrlSetState(-1, $GUI_HIDE)
$SS_labCorrect = GUICtrlCreateLabel("Correct!", 350, 20, 177, 33)
GUICtrlSetFont(-1, 20, 600, $CLEARTYPE_QUALITY )
GUICtrlSetColor(-1, $COLOR_GREEN)
GUICtrlSetState(-1, $GUI_HIDE)
GUISetState(@SW_HIDE)
#EndRegion GUI SimonSays Game
#EndRegion GUIs

#Region Post-GUI Variables + Settings
Global $butEvent1, $butEvent2, $butEvent3, $butEvent4, $butEvent5, $butEvent6, $butEvent7, $butEvent89, $butEvent9, $butEvent10, $butEvent11, $butEvent12
Global $Button1, $Button2, $Button3, $Button4, $Button5, $Button6, $Button7, $Button8, $Button9, $Button10, $Button11, $Button12
Global $speed = 1
Global $diff = 10
Global $start = 0
Global $center = 165 ; i do not know if this is actually used
DllCall("UxTheme.dll", "int", "SetWindowTheme", "hwnd", GUICtrlGetHandle($Progress1), "wstr", "", "wstr", "") ;makes progress1 responsive by applying classic theme
#EndRegion Post-GUI Variables + Settings

#Region Main Loop
While $GameRunning = False
	Sleep($loopInterval)
	While $GameRunning = False
		Sleep($loopInterval)
		$nMsg = GUIGetMsg()
		Switch $nMsg ;;;;; TEST GUI ;;;;;
			Case $testButton1
				GUISetState(@SW_SHOW, $GUI_MAIN)
			Case $testButton2
				OpenGame_ProgBar()
			Case $testButton3
				OpenGame_ButtonPop()
			Case $testButton4
				OpenGame_SimonSays()
			Case $testButton5
			Case $testButton6
			Case $testButton7
			Case $testButton8
			Case $butEvent1 ;;;;; END TEST GUI ;;;;;
				GUICtrlSetData($Progress1, 0)
				GUISetState(@SW_SHOW, $GUI_PROGBAR)
			Case $bStartBarGame
				StartGame_ProgBar()
			Case $ButtonStart
				StartGame_ButtonPop()
			Case $GUI_EVENT_CLOSE
				CloseWin()
		EndSwitch
	WEnd ;----------------------------------------------------------------------------------------------------------------

	While $GIP_ProgBar = True And $GameRunning = True ;While ProgBar Game is active
		;sleep($loopInterval)
		GUICtrlSetData($labRange, $timeInRange)
		Global $BarProgress = GUICtrlRead($Progress1)
		If WinActive($titleProgBar) Then
			HotKeySet("{SPACE}", "ProgBar_Action")
		Else
			HotKeySet("{SPACE}")
		EndIf
		$PBMsg = GUIGetMsg()
		Switch $PBMsg
			Case $GUI_EVENT_CLOSE
				CloseWin()
		EndSwitch
	WEnd

	While $GIP_ButtonPop = True And $GameRunning = True        ;While ButtonPop game is active
		$bpMsg = GUIGetMsg()
		Switch $bpMsg
			Case $GUI_EVENT_CLOSE
				CloseWin()
				EndGame_ButtonPop()
			Case $bpMsg ;loops through buttons. touchy code
				For $i = 0 To $ButtonPopMax
					If $bpMsg == Eval("Button" & $i) Then
						$score += 1
						GUICtrlSetData($LScore, $score)
						;GUICtrlDelete(Eval("Button" & $i)) ;this works past 12 but is inconsistent
						GUICtrlSetState(Eval("Button" & $i), $GUI_HIDE)
						If Mod($i, 2) = 0 Then GUICtrlDelete(Eval("Button" & $i))
						ExitLoop
					EndIf
				Next
		EndSwitch
	WEnd ;----------------------------------------------------------------------------------------------------------------

	While $GIP_SimonSays = True and $GameRunning = True
		$ssMsg = GUIGetMsg()
		Switch $ssMsg
			Case $GUI_EVENT_CLOSE
				CloseWin()
				EndGame_SimonSays()
			Case $SS_butStart
				StartGame_SimonSays()
			Case $SS_butNextRound
				SS_NextRound()
			Case $ssMsg
				For $i = 1 to 9
					If $ssMsg == Eval("SS_but" & $i) Then
						$SSClicks += 1
						ConsoleWrite("SSClicks = " & $SSClicks & @CR & "UBound = " & UBound($arrSays) & @CR & @CR)
						SS_CorrectCheck($i)
						ExitLoop
					EndIf
				Next
		EndSwitch
	WEnd
WEnd ;----------------------------------------------------------------------------------------------------------------
#EndRegion Main Loop

#Region GAME - Progress Bar
Func OpenGame_ProgBar()
	GUISetState(@SW_SHOW, $GUI_PROGBAR)
	ProgBar_PlaceLines()
EndFunc

Func ProgBar_PlaceLines()
	$diff = 6 - $difficulty
	$equationPos = (220 + $diff * 5 - $diff * 10) + $diff * -20 ;position of right bar, based on difficulty. MATHS
	$equationNeg = (250 + $diff * 5 + $diff * 10) + $diff * -20 ;postiion of left bar, based on difficulty. MATHS
	$failPercentRight = ($equationPos * 3) + 33
	$failPercentLeft = ($equationNeg * 3) + 33
	$barFailLeft = GUICtrlCreateLabel("|", $equationPos, $progBarTop, $progBarWidth, $progBarHeight)
	GUICtrlSetFont(-1, 35, 300)
	$barFailRight = GUICtrlCreateLabel("|", $equationNeg, $progBarTop, $progBarWidth, $progBarHeight)
	GUICtrlSetFont(-1, 35, 300)
	ProgBar_CalcFail()
EndFunc

Func ProgBar_CalcFail()
	$ProgBar_FailBarLeft = ControlGetPos("", "", $barFailLeft)
	$ProgBar_FailPctLeft = ($ProgBar_FailBarLeft[0] - 33) / 3
	$ProgBar_FailBarRight = ControlGetPos("", "", $barFailRight)
	$ProgBar_FailPctRight = ($ProgBar_FailBarRight[0] - 33) / 3
EndFunc

Func StartGame_ProgBar()
	Global $GIP_ProgBar = True
	Global $GameRunning = True
	HotKeySet("{SPACE}", "ProgBar_Action")
	Adlib_ProgBar()
	AdlibRegister("Adlib_ProgBar", 100)
	AdlibRegister("ProgBar_TimeInRangeCalc", 100)
EndFunc

Func Adlib_ProgBar() ;adlibbed
	GUICtrlSetData($Progress1, (GUICtrlRead($Progress1) + Random(1, 5))) ;final 2 ints must correspond with adlib speed of this function
	If GUICtrlRead($Progress1) = 100 Then
		MsgBox(0, "", "done", 1)
		AdlibUnRegister("Adlib_ProgBar")
		AdlibUnRegister("ProgBar_TimeInRangeCalc")
	EndIf
EndFunc

Func ProgBar_TimeInRangeCalc() ;adlibbed
	If GUICtrlRead($Progress1) > $ProgBar_FailPctLeft And GUICtrlRead($Progress1) < $ProgBar_FailPctRight Then
		$timeInRange += .1
		GUICtrlSetData($labRange, $timeInRange)
	EndIf
EndFunc

Func ProgBar_Action()
	$percent = GUICtrlRead($Progress1)
	GUICtrlSetData($Progress1, $percent - Random(10, 20, 1))
EndFunc   ;==>ProgBar_Action

Func GBar_Timer()
	ConsoleWrite("timer ticker progress here" & @CRLF)
EndFunc

Func EndGame_ProgBar()
	HotKeySet("", "ProgBar_Action") ;unbinds SPACE and the action function
	$GIP_ProgBar = False
	$GameRunning = False
	AdlibUnRegister("Adlib_ProgBar")
	AdlibUnRegister("ProgBar_TimeInRangeCalc")
EndFunc
#EndRegion GAME - Progress Bar

#Region GAME - ButtonPop
Func OpenGame_ButtonPop()
	GUISetState(@SW_SHOW, $GUI_BUTTONPOP)
EndFunc

Func StartGame_ButtonPop()
	$GIP_ButtonPop = True
	GameRunCheck()
	AdlibRegister("Adlib_ButtonPop", $TimeBetweenButtonSpawns)
	GUICtrlDelete($ButtonStart)
EndFunc

Func Adlib_ButtonPop() ;Adlibbed
	BoxPop($start + 1) ;populates box, first time running would populate Button1 etc etc
	$start += 1           ;increments the actual start var
EndFunc

Func BoxPop($arg)
	Local $height = Random(30, 70, 1)
	Local $width = Random(30, 70, 1)
	Local $x = Random(1, 615 - $width - 2, 1) ;x coord between 1 and the width of the game window
	Local $y = Random(1, 437 - $height - 2, 1) ;y coord between 1 and the height of the game window
	Assign("Button" & $arg, GUICtrlCreateButton("", $x, $y, $height, $width))
	If $arg = $ButtonPopMax Then
		AdlibRegister("EndGame_ButtonPop", $TimeBetweenButtonSpawns / 2)
	EndIf
EndFunc

Func EndGame_ButtonPop() ;fuckery
	If $DNT_ButtonPop = 1 Then
		AdlibUnRegister("EndGame_ButtonPop")
		$GIP_ButtonPop = False
		MsgBox(0, "", "buttonpop game over")
		$GameRunning = False
		$DNT_ButtonPop = 0
	Else
		$DNT_ButtonPop = 1
		AdlibUnRegister("Adlib_ButtonPop")
	EndIf
EndFunc
#EndRegion GAME - ButtonPop

#Region GAME - Simon Says
Func OpenGame_SimonSays()
	GUISetState(@SW_SHOW, $GUI_SIMONSAYS)
	SSButtons("disable")
	$GIP_SimonSays = True
	GameRunCheck()
EndFunc

Func StartGame_SimonSays()
	$score = 0
	GUICtrlSetState($SS_butStart, $GUI_HIDE)
	CalcTheSays()
EndFunc

Func CalcTheSays()
	Local $numSays = $SScurrentLevel + $difficulty
	Global $arrSays[0]
	For $i = 1 to $numSays
		Assign("Say" & $i, Random(1,9,1))
		_ArrayAdd($arrSays, Eval("Say" & $i))
	Next
	AnimateTheSays()
EndFunc

Func AnimateTheSays()
	For $i = 0 to UBound($arrSays)-1
		SS_Anim($arrSays[$i])
	Next
	SSButtons("enable")
EndFunc

Func SS_CorrectCheck($arg)
	If UBound($arrSays) <> 0 Then
		If $arg = $arrSays[0] Then
			 _ArrayDelete($arrSays, 0)
			 SS_Correct()
			 If UBound($arrSays) == 0 Then SS_RoundOver()
		Else
			 SS_Incorrect()
		EndIf
		Elseif @error Then
		SS_RoundOver()
	Else
		SS_RoundOver()
	EndIf
EndFunc

Func SS_RoundOver()
	SS_Correct()
	$SScurrentLevel += 1
	GUICtrlSetData($SS_labLevel, "Level: " & $SScurrentLevel)
	GUICtrlSetState($SS_butNextRound, $GUI_SHOW)
	SSButtons("disable")
EndFunc

Func SS_NextRound()
	GUICtrlSetState($SS_butNextRound, $GUI_HIDE)
	For $i = 1 to 9
		GUICtrlSetState(Eval("SS_but" & $i), $GUI_ENABLE)
	Next
	CalcTheSays()
EndFunc

Func SSButtons($arg)
	For $i = 1 to 9 ;disables the buttons
		If StringLower($arg) = "disable" Then GUICtrlSetState(Eval("SS_but" & $i), $GUI_DISABLE)
		If StringLower($arg) = "enable" Then GUICtrlSetState(Eval("SS_but" & $i), $GUI_ENABLE)
	Next
EndFunc

Func SS_Correct()
	;soundplay perhaps
	$SSCorrectAnim = 0
	SS_Correct_Animation()
	AdlibRegister("SS_Correct_Animation", 500)
EndFunc

Func SS_Correct_Animation()
	If $SSCorrectAnim = 0 Then
		GUICtrlSetState($SS_labCorrect, $GUI_SHOW)
		$SSCorrectAnim = 1
	Else
		GUICtrlSetState($SS_labCorrect, $GUI_HIDE)
	EndIf
EndFunc

Func SS_Incorrect()
	MsgBox(0,"","wrong one")
	EndGame_SimonSays()
EndFunc

Func EndGame_SimonSays()
	GUISetState($GUI_SIMONSAYS, @SW_HIDE)
	$GIP_SimonSays = False
	$GameRunning = False
EndFunc

Func SS_Anim($button)
	GUICtrlSetBkColor(Eval("SS_but" & $button), $SSColor[$button-1][1])
	sleep($animSpeed)
	GUICtrlSetBkColor(Eval("SS_but" & $button), $SSColor[$button-1][2])
	sleep($animSpeed)
	GUICtrlSetBkColor(Eval("SS_but" & $button), $SSColor[$button-1][1])
	sleep($animSpeed)
	GUICtrlSetBkColor(Eval("SS_but" & $button), $SSColor[$button-1][0])
	sleep($animDelay)
EndFunc
#EndRegion GAME - Simon Says

#Region Game Boilerplate
Func OpenGame_NextGame()
EndFunc

Func StartGame_NextGame()
EndFunc

Func Adlib_NextGame()
EndFunc

Func EndGame_NextGame()
EndFunc
#EndRegion Game Boilerplate

#Region Program-wide functions
Func EndGame()
	For $i = 0 To UBound($arr_Games)
		If Eval("GIP_" & $arr_Games[$i]) = True Then
			Assign("GIP_" & $arr_Games[$i], False)
			$GameRunning = False
		EndIf
	Next
	GameRunCheck()
EndFunc

Func GameRunCheck() ;checks if any minigame is currently running, returns bool
	Local $checks = 0
	For $i = 0 To UBound($arr_Games)
		If Eval("GIP_" & $arr_Games[$i]) = True Then
			$GameRunning = True
			Return True
			$checks -= 1
		EndIf
		$checks += 1
		If $checks = UBound($arr_Games) Then
			$GameRunning = False
			Return False
		EndIf
	Next
EndFunc

Func CloseWin()
	If WinActive($titleMain) <> 0 And $testmode = False Then Exit @ScriptLineNumber
	If WinActive($titleTest) <> 0 Then Exit @ScriptLineNumber
	For $i = 0 To UBound($arr_Games)
		If WinActive(Eval("title" & $arr_Games[$i])) <> 0 Then
			GUISetState(@SW_HIDE, Eval("GUI_" & $arr_Games[$i]))
			ExitLoop
		Else
			ContinueLoop
		EndIf
	Next
	$GameRunning = False
EndFunc
#EndRegion Program-wide functions

#Region Test Functions
Func TestFunc()
	_ArrayDisplay($arrSays)
EndFunc

;~ Func TestFunc()
;~ 	$percentage = InputBox("percentage", "enter percentage", "", "")
;~ 	ConsoleWrite("Creating bar at " & $percentage & "%" & @CRLF)
;~ 	$x = ($percentage*3) +33
;~ 	ConsoleWrite("x: " & $x & @crlf)
;~ 	$testlabel = GUICtrlCreateLabel("|", $x, 33, 10, 45)
;~ 	GUICtrlSetFont(-1, 35, 300)
;~ 	$Progress1 = GUICtrlCreateProgress(40, 49, 300, 25)
;~ EndFunc

Func TestFunc2()
	$testpos = ControlGetPos("", "", $testlabel) ;pixel position of the bar
	ConsoleWrite("testpos: " & $testpos[0] & @CRLF)
	$testpct = ($testpos[0] - 33) / 3
	ConsoleWrite("!Pct is: " & $testpct & @CRLF)
EndFunc

Func Terminate()
	Exit @ScriptLineNumber
EndFunc
#EndRegion Test Functions
