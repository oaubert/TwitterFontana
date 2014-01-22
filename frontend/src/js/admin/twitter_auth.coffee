###
# Fontana Twitter authentication
###

@Fontana ?= {}


class @Fontana.TwitterAuth
    # Wrapper for the Twitter oAuth process

    activeSession: (callback)->
        # Check if there's an active Twitter session.
        # Calls the given callback with an object containing the current
        # twitter screen_name, or null if there's no active session.
        $.get('/api/twitter/session/').success((data)->
            callback(data))
        .error(->
            callback(null))

    signIn: (callback)->
        # Try to Sign in with Twitter. Opens a pop-up that handles all
        # the redirects and return urls. The callback function is only
        # called on completing the sign in flow. The user might abort the
        # sign in process by closing the pop up, this is not detectable.
        funcName = String.fromCharCode(Math.floor(Math.random() * 24) + 65) + (new Date()).getTime()
        window[funcName] = callback
        width = 700
        height = 700
        left = (window.screen.width + width) / 2
        top = (screen.height + height) / 2
        url = "/api/twitter/session/new/?next=/pop/twitter_success.html" + encodeURIComponent("?callback=#{funcName}")
        windowName = "twitterFontanaLogin"
        windowFeatures = "location=0,menubar=0,status=0,width=#{width},height=#{height},top=#{top},left=#{left}"
        window.open(url, windowName, windowFeatures).focus()

    signOut: (callback)->
        # Sign out. This completely resets the current session.
        $.post('/api/session/clear/').success(callback)
