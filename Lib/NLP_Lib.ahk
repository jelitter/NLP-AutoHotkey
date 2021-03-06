ObjCount(Obj) {
  if (!IsObject(Obj))
    return 0
  z:=0
  for k in Obj
    z+=1 ;or z:=A_Index
  return z
}

getSentimentScore(txt="", lang="es") {

  capsMultiplier := 1.2

  txt := StrReplace(txt, "`n", "", A)
  txt := StrReplace(txt, "`r", "", A)
  txt := StrReplace(txt, ".", " ", A)
  txt := StrReplace(txt, ",", " ", A)
  txt := StrReplace(txt, "/", " ", A)
  txt := StrReplace(txt, "(", " ", A)
  txt := StrReplace(txt, ")", " ", A)
  txt := StrReplace(txt, "  ", " ", A)

  if (txt = "")
    Return

  if (lang = "en") {
    FileRead, allwords, % "Data\warriner-english.json"
  } else {
    FileRead, allwords, % "Data\warriner-spanish.json"
  }
  wordRatings   := JSON.parse(allwords)

  words := StrSplit(txt, " ")
  totalWords := words.Length()
  totalScore := 0 
  totalScoredWords := 0
  scoredWords := []

  for w in words {

    allCaps := (Trim(words[w]) ~= Trim(toUpper(words[w])))
    ; msgbox % "Word: " words[w] " - Upper: " toUpper(words[w]) " - AllCaps: " allCaps

    RegExMatch(words[w], "(*UCP)(\w+)", match)
    words[w] := toLower(match1)


    words[w] := toLower(words[w])

    word := words[w]

    if (lang = "es")
      stem := stemSpanish(word)
    
    if (wordRatings[stem]) and (lang = "es") {

      if allCaps
      {
        if wordRatings[stem] < 4.50
          capsMultiplier := 0.5
        totalScore += limit(wordRatings[stem] * capsMultiplier, 1, 9)
      }
      else
        totalScore += wordRatings[stem]

      totalScoredWords++

      if scoredWords[stem] {
        scoredWords[stem].count ++
        if !hasValue(scoredWords[stem].forms, word) {
          scoredWords[stem].forms.push(word)
        }
      } else {
        thisWord := { "display" : stem " (" wordRatings[stem] " : " toPercent(wordRatings[stem]) "%)"
                    , "count" : 1, "forms" : [word]  }
        scoredWords[stem] := thisWord
      }
    }
    ; Stem not in dictionary, search word instead    
    else if (wordRatings[word]) {
      
      if allCaps
      {
        if wordRatings[word] < 4.50
          capsMultiplier := 0.5
        totalScore += limit(wordRatings[word] * capsMultiplier, 1 , 9)
      }
      else
        totalScore += wordRatings[word]

      totalScoredWords++
      
      if scoredWords[word] {
        scoredWords[word].count ++
        if !hasValue(scoredWords[word].forms, word) {
          scoredWords[word].forms.push(word)
        }
      } else {
        thisWord := { "display" : word " (" wordRatings[word] " : " toPercent(wordRatings[word]) "%)"
                    , "count" : 1, "forms" : [word] }
        scoredWords[word] := thisWord
      }
    }


  }

  if (totalScore > 0) {
    nScoredWords := scoredWords.SetCapacity(0)
    score  := totalScore/totalScoredWords  ;; 1 -- 9
    scoreP := toPercent(score)             ;; 0 -- 100
  }
  Return { "score"      : score
         , "scoreP"     : scoreP
         , "nwords"     : nScoredWords
         , "twords"     : totalScoredWords
         , "totalWords" : totalWords
         , "words"      : scoredWords }
}

toPercent(n) {
  return round((n*100) / 9, 2)
}

stemSpanish(word) {
  ; http://snowball.tartarus.org/algorithms/spanish/stemmer.html

  ; Pre: Get R1 and R2
  ; R1 := R2 := ""
  ; firstConsonantFound := False
  ; firstVowelFound := False

  R1 := getR(word)
  R2 := getR(R1)
  RV := getRV(word)

  ; ┌──────────────────────────┐
  ; │ Step 0: Attached pronoun │
  ; └──────────────────────────┘
  
  if RegExMatch(RV, "(iéndo|ándo|ár|ér|ír|ando|iendo|ar|er|ir|yendo)((?:selas|selos|sela|selo|las|les|los|nos|la|le|lo|me|se|te))", match) {

    rep := word

    if match1 in iéndo,ándo,ár,ér,ír
    {
      match1p := StrReplace(match1, "á", "a", A)
      match1p := StrReplace(match1p, "é", "e", A)
      match1p := StrReplace(match1p, "í", "i", A)
      match1p := StrReplace(match1p, "ó", "o", A)
      match1p := StrReplace(match1p, "í", "u", A)
      rep     := StrReplace(rep, match1, match1p)
    }
    rep := SubStr(rep, 1, strlen(rep) - StrLen(match2))
    return rep
  }


  ; ┌─────────────────────────────────┐
  ; │ Step 1: Standard suffix removal │
  ; └─────────────────────────────────┘

  suffixRemoved := False

  if RegExMatch(R2, "(amientos\b|imientos\b|imiento\b|amiento\b|ables\b|anzas\b|ibles\b|ismos\b|istas\b|able\b|anza\b|ible\b|icas\b|icos\b|ismo\b|ista\b|osas\b|osos\b|ica\b|ico\b|osa\b|oso\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1))
  }

  if RegExMatch(R2, "(aciones\b|adoras\b|adores\b|ancias\b|ación\b|adora\b|ancia\b|antes\b|ador\b|ante\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1))
  }

  if RegExMatch(R2, "(logías\b|logía\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) "log"
  }

  if RegExMatch(R2, "(uciones\b|ución\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) "u"
  }

  if RegExMatch(R2, "(encias\b|encia\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) "ente"
  }

  if InStr(R1, "amente") {
    suffixRemoved := True
    return StrReplace(word, "amente", "")
  }  

  if RegExMatch(R2, "((?:ativamente\b|ivamente\b)|(?:osamente\b|icamente\b|adamente\b)|(?:antemente\b|ablemente\b|iblemente\b)|(?:mente\b))", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) 
  }

  if RegExMatch(R2, "((?:abil|ic|iv)(?:idad\b|idades\b)|(?:idad\b|idades\b))", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) 
  }

  if RegExMatch(R2, "(idad\b|idades\b)", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) 
  }

  if RegExMatch(R2, "((?:at)?(?:ivos?|ivas?))", match) {
    suffixRemoved := True
    return SubStr(word, 1, strlen(word) - strlen(match1)) 
  }


  if (!suffixRemoved) {
    ; Do step 2a if no ending was removed by step 1.
    ; ┌────────────────────────────────────┐
    ; │ Step 2a: Verb suffixes beginning y │
    ; └────────────────────────────────────┘

    if RegExMatch(RV, "u(yamos\b|yendo\b|yeron\b|yais\b|yan\b|yas\b|yen\b|yes\b|ya\b|ye\b|yo\b|yó\b)", match) {
      suffixRemoved := True
      return SubStr(word, 1, strlen(word) - strlen(match1)) 
    }
    else {

      ; Do Step 2b if step 2a was done, but failed to remove a suffix. 
      ; ┌──────────────────────────────┐
      ; │ Step 2b: Other verb suffixes │
      ; └──────────────────────────────┘

      if RegExMatch(RV, "(g(u(?:emos|éis|en|es)))", match) {
        return SubStr(word, 1, strlen(word) - strlen(match2)) 
      }

      if RegExMatch(RV, "(aríamos\b|eríamos\b|iríamos\b|iéramos\b|iésemos\b|"
                      . "aremos\b|aríais\b|asteis\b|eremos\b|eríais\b|ierais\b|ieseis\b|iremos\b|iríais\b|isteis\b|ábamos\b|áramos\b|ásemos\b|"
                      . "abais\b|arais\b|aréis\b|arían\b|arías\b|aseis\b|eréis\b|erían\b|erías\b|iendo\b|ieran\b|ieras\b|ieron\b|iesen\b|ieses\b|iréis\b|irían\b|irías\b|íamos\b|"
                      . "aban\b|abas\b|adas\b|ados\b|amos\b|ando\b|aran\b|aras\b|aron\b|arán\b|arás\b|aría\b|asen\b|ases\b|aste\b|erán\b|erás\b|ería\b|idas\b|idos\b|iera\b|iese\b|imos\b|irán\b|irás\b|iría\b|iste\b|íais\b|"
                      . "aba\b|ada\b|ado\b|ara\b|ará\b|aré\b|ase\b|erá\b|eré\b|ida\b|ido\b|irá\b|iré\b|áis\b|ían\b|ías\b|"
                      . "ad\b|an\b|ar\b|as\b|ed\b|er\b|id\b|ir\b|ió\b|ía\b|ís\b)", match) {
        return SubStr(word, 1, strlen(word) - strlen(match1)) 
      }
    }
  }

  ; ┌─────────────────────────┐
  ; │ Step 3: residual suffix │
  ; └─────────────────────────┘

  if RegExMatch(RV, "(os\b|a\b|o\b|á\b|í\b|ó\b)", match) {
    return SubStr(word, 1, strlen(word) - strlen(match1)) 
  }

  if RegExMatch(RV, "(g(u(?:e|é))", match) {
    return SubStr(word, 1, strlen(word) - strlen(match2)) 
  }

  ; ┌───────────────────────────────┐
  ; │ Finally: Remove acute accents │
  ; └───────────────────────────────┘

  word := StrReplace(RV, "á", "a")
  word := StrReplace(RV, "é", "e")
  word := StrReplace(RV, "í", "i")
  word := StrReplace(RV, "ó", "o")
  word := StrReplace(RV, "í", "u")

  ; ┌──────────────┐
  ; │ Stemming end │
  ; └──────────────┘

  return ; word
}

stemSpanish2(word) {
  return stemsSpanish[word]
}

stemEnglish(word) {
  ; Porter2 Algorithm
  ; http://snowball.tartarus.org/algorithms/english/stemmer.html

  if (StrLen(word) <= 2)
    return word

  vowel            := "[aeiouy]"     
  non_vowel        := "[^aeiouy]"
  double           := "[bdfgmnprt]{2}"
  li_ending        := "[cdeghkmnrt]"
  short_syllable_a := non_vowel + "([^aeiouywx][aeiouy])"
  short_syllable_a := "^(" + vowel + non_vowel + ")"

  ; TO DO

  word := StrReplace(word, "'", "")
  return
}

getR(word) {
  ; http://snowball.tartarus.org/texts/r1r2.html
  ; R1 is the region after the first non-vowel following a vowel, or is the null region at the end of the word if there is no such non-vowel. 
  ; R2 is the region after the first non-vowel following a vowel in R1, or is the null region at the end of the word if there is no such non-vowel. 

  firstVowelFound := False
  firstConsonantFound := False

  loop % StrLen(word)
  {
    letter := SubStr(word, A_Index, 1)

    if (!firstVowelFound) {
      if letter in a,e,i,o,u,á,é,í,ó,ú
      {
        firstVowelFound := True
      }
    } else {
      if (!firstConsonantFound) {
        if letter not in a,e,i,o,u,á,é,í,ó,ú 
        {
          firstConsonantFound := True
          Continue
        }
      } else {
        Return SubStr(word, A_Index)
      }
    }
  }
  return
}

getRV(word) {
  ; http://snowball.tartarus.org/algorithms/spanish/stemmer.html
  
  ; 1. If the second letter is a consonant, RV is the region after the next following vowel, 
  ; 2. or if the first two letters are vowels, RV is the region after the next consonant,
  ; 3. and otherwise (consonant-vowel case) RV is the region after the third letter.
  ; 4. But RV is the end of the word if these positions cannot be found. 

  secondLetter := SubStr(word, 2, 1)

  ; 1.
  if secondLetter not in a,e,i,o,u,á,é,í,ó,ú 
  {
    firstVowelFound := False

    loop % StrLen(word) - 2
    {
      letter := SubStr(word, A_Index+2, 1)
      ; msgbox % "word: " word " - letter: " letter "`n" SubStr(word, 1, A_Index+2)
      if !firstVowelFound {
        if letter in a,e,i,o,u,á,é,í,ó,ú 
        {
          firstVowelFound := True
          Continue
        }
      } else {
        Return SubStr(word, A_Index+2)
      }
    }
  }

  ; 2.
  else if SubStr(word, 1, 1) in a,e,i,o,u,á,é,í,ó,ú 
  and SubStr(word, 2, 1) in a,e,i,o,u,á,é,í,ó,ú 
  {
    firstConsonantFound := False

    loop % StrLen(word) - 2
    {
      letter := SubStr(word, A_Index+2, 1)
      if !firstConsonantFound {
        if letter not in a,e,i,o,u,á,é,í,ó,ú 
        {
          firstConsonantFound := True
          Continue
        }
      } else {
        Return SubStr(word, A_Index+2)
      }
    }
  }

  ; 3.
  else {
    Return SubStr(word, 4)
  }
  Return
}

toLower(string="") {
  return Format("{:L}", string)
}

toUpper(string="") {
  return Format("{:U}", string)
}

hasValue(arr, v) {
  for i in arr
  {
    if arr[i] = v
      return true
  }
  return false
}

isVowel(c) {
  return c is in a,e,i,o,u,y
}

isDouble(c) {
  return c is in bb,dd,ff,gg,mm,nn,pp,rr,tt
}

isShortSylabe(syl) {
  ; Define a short syllable in a word as either 
  ; (a) a vowel followed by a non-vowel other than w, x or Y and preceded by a non-vowel,
  ; (b) a vowel at the beginning of the word followed by a non-vowel. 

  a := "([^aeiouy](?:a|e|i|o|u|y)[^aeiouywx])"
  b := "(\b[aeiouy][^aeiouy])"

  Return RegExMatch(syl, a) or RegExMatch(syl, b)
}

isLiEnding(c) {
  return c is in c,d,e,g,h,k,m,n,r,t
}