#KeyHistory 0
#MaxThreadsPerHotkey,1
#NoEnv
#SingleInstance force
CoordMode, Mouse, Screen
CoordMode, Pixel, Screen
CoordMode, Tooltip, Screen
DetectHiddenText, On
DetectHiddenWindows, On
ListLines Off
Process, Priority,, High
SetBatchLines -1
SetControlDelay, 0
SetKeyDelay, 0
SetMouseDelay, 0
SetTitleMatchMode, 2
SetWinDelay, 0

#Persistent
#Include Lib\Consts.ahk
#Include Lib\NLP_Lib.ahk
#Include Lib\UI_Lib.ahk
#Include Lib\Lyrics.ahk


createUI()
Return


GuiSize: 
{
  guiHeight := A_GuiHeight
  guiWidth  := A_GuiWidth

  LeftButtonPos   := "x" GuiMargin                " y" GuiMargin " w" A_GuiWidth/6 - GuiMargin*1.5 " h" 50
  RightButtonPos  := "x" GuiMargin + A_GuiWidth/6 - GuiMargin/2 " y" GuiMargin " w" A_GuiWidth/6 - GuiMargin*1.5 " h" 50
  QButtonPos      := "x" GuiMargin + A_GuiWidth/3 - GuiMargin " y" GuiMargin " w" A_GuiWidth/6 - GuiMargin " h" 50

  LeftPannelPos  := "x" GuiMargin                  " y" 2*GuiMargin + 50
                 . " w" A_GuiWidth/2 - GuiMargin*2 " h" A_GuiHeight - GuiMargin*3 -70
  TopRightPannelPos := "x" A_GuiWidth/2  " y" GuiMargin 
                     . " w" A_GuiWidth/2 - GuiMargin " h" 110
  
  BotRightPannelPos := "x" A_GuiWidth/2  " y" GuiMargin*2 + 110 
                     . " w" A_GuiWidth/2 - GuiMargin " h" A_GuiHeight - GuiMargin*2 -145
                     


  LeftShadowPos  := "x" GuiMargin + GuiMargin/2    " y" GuiMargin + GuiMargin/2
                 . " w" A_GuiWidth/2 - GuiMargin*2 " h" A_GuiHeight - GuiMargin*2 -20
  RightShadowPos := "x" A_GuiWidth/2  + GuiMargin/2 " y" GuiMargin + GuiMargin/2
                 . " w" A_GuiWidth/2 - GuiMargin " h" A_GuiHeight - GuiMargin*2 -20


  GuiControl, MoveDraw, LeftButton,      % LeftButtonPos
  GuiControl, MoveDraw, RightButton,     % RightButtonPos
  GuiControl, MoveDraw, QButton,         % QButtonPos
  GuiControl, Move, LeftShadow,      % leftShadowPos
  GuiControl, Move, RightShadow,     % rightShadowPos
  GuiControl, Move, LeftPannel,      % LeftPannelPos
  GuiControl, Move, TopRightPannel,  % TopRightPannelPos
  GuiControl, Move, BotRightPannel,  % BotRightPannelPos
  Return
}

GuiEscape:
GuiClose:
ExitApp
Return

^#R::
Reload
Return


#Include Lib\JSON.ahk
