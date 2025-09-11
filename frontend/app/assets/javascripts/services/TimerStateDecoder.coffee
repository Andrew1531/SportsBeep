angular.module('sportsbeep.services').service 'TimerStateDecoder', ($q, $timeout, TicketPlayer, TicketSquad, GamePositionService, GameSquadService, NullPlayer, NullTeam) ->

  class TimerStateDecoder
    constructor: (timerStateTexts)->
      @mSeconds = 14
      @mPrecision = 10

    generateTimerStateMap: (ticketId, timerStateTexts) ->
      @ticketId = ticketId
      @timerStateMap = {}

      $q (resolve, reject) =>
        @realFunction timerStateTexts, 0, =>
          resolve(@timerStateMap)

    realFunction: (timerStateTexts, index, callback) ->
      encryptedText = timerStateTexts[index].encrypted_text
      timeValue = @decode(@ticketId, encryptedText)
      @timerStateMap[timeValue] = encryptedText
      if index < (timerStateTexts.length - 1)
        $timeout =>
          @realFunction timerStateTexts, index + 1, callback
      else
        callback()

    decode: (ticketId, timerStateText) ->
      randomSalt = timerStateText.substring(0, 6)
      cipherText = CryptoJS.enc.Base64.parse timerStateText.substring(6)

      for s in [0..@mSeconds]
        for p in [0..@mPrecision]
          continue if (s > 0 && p is 0)

          positionalSalt = "#{s}:#{p}"
          key = ""
          while key.length < 32
            key += ":#{randomSalt}:#{positionalSalt}:#{ticketId}:#{randomSalt}:"

          key = key.substring(0, 32) if key.length > 32

          iv = CryptoJS.enc.Utf8.parse key.substring(0, 16)
          k  = CryptoJS.enc.Utf8.parse key

          decrypted = CryptoJS.AES.decrypt
            ciphertext: cipherText
          , k,
            iv: iv
            mode: CryptoJS.mode.CBC
            padding: CryptoJS.pad.Pkcs7

          try
            plainText = decrypted.toString(CryptoJS.enc.Utf8)
            if plainText.indexOf(positionalSalt) is 0
              return plainText.substring(positionalSalt.length + 1)
          catch

      undefined

  new TimerStateDecoder