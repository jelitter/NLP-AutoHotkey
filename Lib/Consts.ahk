;   ##################################################
;   ##                                              ## 
;   ##                   CONSTANTS                  ## 
;   ##                                              ## 
;   ##################################################


global stemsSpanish
FileRead, ss, Data\stems_spanish.json
stemsSpanish := JSON.parse(ss)
VarSetCapacity(ss, 0)
ss =

global Quijote         := ""
global nlpVersion      := "1.0.0"
; global BackgroundColor := 0xB8D4DD
; global TextColor       := 0x226688
global BackgroundColor := 0xEAEAEA
global TextColor       := 0x454545
global GuiMargin       := 15
global guiWidth        := 1000
global guiHeight       := 800
global guiX            := A_ScreenWidth  - guiWidth -30
global guiY            := A_ScreenHeight - guiHeight -60
global sep             := "------------------------------------"

global slen := ""
global sles := ""
global nTracksEN := 0
global nTracksES := 0
