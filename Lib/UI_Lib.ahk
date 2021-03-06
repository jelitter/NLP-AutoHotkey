﻿createUI() {

  global



  Menu, TRAY, Icon, imageres.dll, 196
  Menu, Tray, Tip, Natural Language Processing`nisanchez@blizzard.com

  Gui, +HWNDhTemplateSearch
  Gui, +Caption +Border +E0x40000 +Resize +MinSize700x450
  gui, color, % BackgroundColor
  Gui, Margin, 10, 10
  WinSet, ExStyle, +0x20
  WinSet, Transparent, 0

  if FileExist(A_ScriptDir "\Img\back.png") {
    Gui, Add, picture, % leftShadowPos  " vLeftShadow  BackgroundTrans", % A_ScriptDir "\Img\back.png"
    Gui, Add, picture, % rightShadowPos " vRightShadow BackgroundTrans", % A_ScriptDir "\Img\back.png"
  }
  
  Gui, Font, s9 Q5 c%TextColor%, Century Gothic
  Gui, Add, Button, % LeftButtonPos   " vLeftButton   gLeftButton Default"   , Random`nEnglish song
  Gui, Add, Button, % RightButtonPos " vRightButton gRightButton" , Random`nSpanish song
  Gui, Add, Button, % QButtonPos " vQButton gQButton" , Random`nQuijote

  Gui, Font, s12 Q5 c%TextColor%, Century Gothic
  Gui, Add, Edit, % LeftPannelPos  " Multi vLeftPannel gTextEntered"
  Gui, Font, s10 Q5 cBlack, Consolas
  Gui, Add, Edit, % TopRightPannelPos " Multi vTopRightPannel ReadOnly"
  Gui, Add, Edit, % BotRightPannelPos " Multi vBotRightPannel ReadOnly"

  Gui, Add, StatusBar, gStatusBar, % "Ready - Enter Spanish text or begin with EN: for English`t`tIsaac Sanchez, 2017   "
  SB_SetIcon("Shell32.dll", 210)

  Gui, Show , % "x" guiX " y" guiY " w" guiWidth " h" guiHeight, % "Natural Language Processing Tests - v" nlpVersion
  Return
}

StatusBar() {
  Return
}

TextEntered() {
  global
  gui, Submit, NoHide

  if (LeftPannel = "") {
    GuiControl,, LeftPannel
    GuiControl,, TopRightPannel
    GuiControl,, BotRightPannel
    SB_SetText("Ready - Enter Spanish text or begin with EN: for English`t`tIsaac Sanchez, 2017   ")
    Return
  }

  if toLower(SubStr(LeftPannel, 1, 3)) = "en:"
  {
    lang := "EN"
    LeftPannel := SubStr(LeftPannel, 4)
    LeftPannel := Trim(LeftPannel)
    tSent := getSentimentScore(LeftPannel, "en")
  }
  else {
    lang := "ES"
    LeftPannel := Trim(LeftPannel)
    tSent := getSentimentScore(LeftPannel)
  }

  words := JSON.dump(tSent.words, "  ")
  words := StrReplace(words, "\u00E1", "á", A)
  words := StrReplace(words, "\u00E9", "é", A)
  words := StrReplace(words, "\u00ED", "í", A)
  words := StrReplace(words, "\u00F3", "ó", A)
  words := StrReplace(words, "\u00FA", "ú", A)
  words := StrReplace(words, "\u00F1", "ñ", A)

  GuiControl,, TopRightPannel, % box("Sentiment score: " round(tSent.score, 2) " (" tSent.scorep " %)")
                            . "`n " padSpaces(tSent.totalWords, strlen(tSent.totalWords), 1) " total  words"
                            . "`n " padSpaces(tSent.nwords, strlen(tSent.totalWords), 1) " unique scored words"
                            . "`n " padSpaces(tSent.twords, strlen(tSent.totalWords), 1) " total  scored words"
                            
  GuiControl,, BotRightPannel, % words

  SB_SetText("Ready - [" lang "] Score: " tSent.score " (" tSent.scoreP " %)`t`tIsaac Sanchez, 2017   ")
  Return
}

LeftButton() {
  global
  if !IsObject(slen)
    GuiControl,, LeftPannel, Loading...
  ly := getRandomLyric("en")
  if (ly.lang = "en") {
    LeftPannel := "en:`n" sep "`n" ly.song "`n" ly.artist "`n" sep "`n`n" ly.lyrics
    GuiControl,, LeftPannel, % LeftPannel
  }
  else {
    LeftPannel := sep "`n" ly.song "`n" ly.artist "`n" sep "`n`n" ly.lyrics
    GuiControl,, LeftPannel, % LeftPannel
  }
  TextEntered()
  Return
}

RightButton() {
  global
  if !IsObject(sles)
    GuiControl,, LeftPannel, Loading...
  ly := getRandomLyric("es")
  if (ly.lang = "en") {
    LeftPannel := "en:`n" sep "`n" ly.song "`n" ly.artist "`n" sep "`n`n" ly.lyrics
    GuiControl,, LeftPannel, % LeftPannel
  }
  else {
    LeftPannel := sep "`n" ly.song "`n" ly.artist "`n" sep "`n`n" ly.lyrics
    GuiControl,, LeftPannel, % LeftPannel
  }
  TextEntered()
  Return
}

QButton() {
  LeftPannel := getRandomQuijoteParagraph()
  GuiControl,, LeftPannel, % LeftPannel
  TextEntered()
  Return
}

getRandomQuijoteParagraph() {

  if !IsObject(Quijote) {
    FileRead, qui, Data\Quijote.txt
    Quijote := StrSplit(qui, "`n`r")
  }

  txt := ""
  while (StrLen(txt) < 100)
   txt := Trim(Quijote[rand(Quijote.Length())])

  return txt
}

padSpaces(String, Length, side=0) {
  ; Returns String with added spaces to reach Length.
  ; 0=Left       "Text      "
  ; 1=Right      "      Text"
  ; 2=Centered   "   Text   "

  ; Right
  if ((side = 1) or (side ="right")) {
    while strlen(string) < length
      String := " " String
  }
  ; Left
  else if ((side = 0) or (side ="left")) {
    while strlen(string) < length
      String := String " "
  }
  ; Center
  else if ((side = 2) or (side ="center")) {
    while strlen(string) < length
    {
      if Mod(A_Index, 2)
        String := " " String
      else
        String := String " "
    }
  }
  return String
}

box(txt) {
  
  topLine := ""
  botLine := ""
  midLine := ""
  midLines := ""
  ctl := "┌"   ; Corner top left
  cbl := "└"
  ctr := "┐"
  cbr := "┘"
  hl  := "─"    ; Horizontal line
  vl  := "│"    ; Vertical line

  maxLen := 0
  lines := StrSplit(txt, "`n")
  for l in lines 
  {
    if strlen(lines[l]) > maxLen
      maxLen := strlen(lines[l])
  }
  midLines := ""
  limitter := maxLen + 5
  for l in Lines
  {
    thisl := trim(lines[l])
    StringReplace, thisl, thisl, `n,, All
    StringReplace, thisl, thisl, `r,, All
    thisl := vl " " thisl spaces(2 + maxLen - strlen(lines[l])) vl "`n"

    while strlen(thisl) > limitter
      StringReplace, thisl, thisl, % "  ", % " "
    while strlen(thisl) < limitter
      StringReplace, thisl, thisl, % " ", % "  "

    midLines .= thisl
  }
  topLine .= ctl hls(maxLen+2) ctr "`n"
  botLine .= cbl hls(maxLen+2) cbr
  Return topLine midLines botLine
}

spaces(n) {
  s := ""
  loop, % n
  s .= " "
  return % s
}

hls(n) {       ; Horizontal lines
  l := ""
  loop, % n
  l .= "─"
  return % l
}

limit(num, lower, upper) {
  if (num < lower)
    return lower
  if (num > upper)
    return upper
  return num
}
