getRandomLyric(lang="EN") {
  ; https://developer.musixmatch.com/admin/applications
  ; Token: 676f595ad74e77437317104e2aae726a
  ; https://developer.musixmatch.com/documentation/api-methods
	apiKey := "ENTER_YOUR_API_KEY_HERE"
	apiURL := "http://api.musixmatch.com/ws/1.1/"
	trackURL := "http://api.musixmatch.com/ws/1.1/track.lyrics.get?apikey=" apiKey "&track_id="
	songListUS := apiURL "chart.tracks.get?page=1&page_size=100&country=US&f_has_lyrics=1&apikey=" apiKey
	songListES := apiURL "chart.tracks.get?page=1&page_size=100&country=ES&f_has_lyrics=1&apikey=" apiKey


  if (lang="EN") and (nTracksEN = 0) {
  	try 
  	{
  		slen := getAPI(songListUS)
      nTracksEN := slen.message.body.track_list.Length()
      ; msgbox % "Retrieved list of " nTracksEN " English tracks."
  	} Catch, e {
  		msgbox % "Error getting English song list.`n" e.Status
  	}
  }

  if (lang="ES") and (nTracksES = 0) {
    try 
    {
      sles := getAPI(songListES)
      nTracksES := sles.message.body.track_list.Length()
      ; msgbox % "Retrieved list of " nTracksES " Spanish tracks."
    } Catch, e {
      msgbox % "Error getting Spanish song list.`n" JSON.dump(e, " ")
    }
  }

  if (lang="EN") {
    rTrack := rand(nTracksEN)
    trackID := slen.message.body.track_list[rTrack].track.track_id
  } else {
    rTrack := rand(nTracksES)
    trackID := sles.message.body.track_list[rTrack].track.track_id
  }

  try {
    ly := getAPI(trackURL trackID)
    lyrics := ly.message.body.lyrics.lyrics_body 

    if RegExMatch(lyrics, "(\*+?.+?This Lyrics is NOT for Commercial use.?\*+)", match) {
      lyrics := RegExReplace(lyrics, "(\*+?.+?This Lyrics is NOT for Commercial use.?\*+)")
    }

  } catch {
      msgbox % "Error getting track info.`n" JSON.dump(e, " ")
  }

  if (lang = "en") {
    return { "Artist" : slen.message.body.track_list[rTrack].track.artist_name
           , "Song"   : slen.message.body.track_list[rTrack].track.track_name
           , "Lyrics" : lyrics
           , "lang"   : ly.message.body.lyrics.lyrics_language }
  } else {
    return { "Artist" : sles.message.body.track_list[rTrack].track.artist_name
           , "Song"   : sles.message.body.track_list[rTrack].track.track_name
           , "Lyrics" : lyrics
           , "lang"   : ly.message.body.lyrics.lyrics_language }
  }
}

getAPI(URL="") {
  if (URL ="")
    Return -1

  Try {
    w := ComObjCreate("WinHTTP.WinHttpRequest.5.1")
    w.Open("GET", URL, True)
    w.Send("")
    w.WaitForResponse()

    if (w.Status = "200" or w.StatusText = "OK")
      return JSON.parse(w.ResponseText)
    else
      return { "Status"     : "" w.Status ""
             , "StatusText" : "" w.StatusText "" }
  }
  Catch e {
    msgbox % "Exception thrown:`n" url "`n" JSON.dump(e, " ")
    return { "Status" : "nok" }
  }
}

rand( a=0.0, b=1 ) {
  if IsObject(a) {
    return a[rand(a.Length())]
  }

  IfEqual,a,,Random,,% r := b = 1 ? Rand(0,0xFFFFFFFF) : b
  Else Random,r,a,b
  Return r
}

