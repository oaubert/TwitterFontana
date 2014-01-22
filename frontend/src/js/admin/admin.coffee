# Bootswatch stylesheets
styles =
    Spacelab:
        stylesheet: "/bootstrap/spacelab/bootstrap.min.css"
        description: "Silvery and sleek"

transitions =
    "Slide": "slide"

# Tying things together to make the demo page work
$ ->
    controls = $("#controls")
    signIn = $("#signin")
    signOut = $("#signout")
    auth = new Fontana.TwitterAuth()
    container = $(".fontana")
    visualizer = null
    settings = null
    refreshsource = null

    fetchSettings = ->
        $.get("/pop/settings.html", now: (new Date()).getTime()).success (data) ->
            settings = $(data)
            settings.css(
                position: "absolute"
                top: "40px"
                left: 0
            )
            $('form', settings).submit (e) ->
                e.preventDefault()
                return false
            $('.close', settings).click () ->
                settings.hide()
            rigSearchBox(settings)
            rigStyleSwitch(settings)
            rigTransitionSwitch(settings)
            settings.appendTo(document.body)

    rigSearchBox = (settings)->
        input = $("#search", settings)
        if $(document.body).hasClass("signedIn")
            input.attr("disabled", false)
            input.keypress (e) ->
                if(e.which == 13)
                    e.preventDefault()
                    input.change()
                    return false
            input.change ->
                q = $("#search", settings).val()
                if q && q != visualizer.datasource.q
                    twitterFontana(transition: "scroll-down",
                                   $("#search", settings).val())
        else
            input.attr("disabled", true)

    rigStyleSwitch = (settings)->
        select = $("#bootswatch", settings)
        Object.keys(styles).forEach (key) ->
            style = styles[key]
            select.append("<option value='#{style.stylesheet}'>#{key} &mdash; #{style.description}</option>")
        select.change (e)->
            $("link.bootswatch", document.head).remove()
            stylesheet = $(e.target).val()
            if stylesheet
                $("<link rel='stylesheet' href='#{stylesheet}' class='bootswatch'>").insertAfter($('link.bootstrap'))

    rigTransitionSwitch = (settings)->
        select = $("#transition", settings)
        Object.keys(transitions).forEach (key) ->
            transition = transitions[key]
            select.append("<option value='#{transition}'>#{key}</option>")
        select.change (e)->
            transition = $(e.target).val()
            visualizer.pause()
            visualizer.config(transition: transition)
            visualizer.resume()

    # Toggles
    toggleSettings = ->
        if !settings
            fetchSettings()
        else
            settings.toggle()

    toggleViz = ->
        icon = $("[class*='icon-']", this)
        if visualizer.paused
            icon.removeClass("icon-play")
            icon.addClass("icon-pause")
            visualizer.resume()
        else
            icon.removeClass("icon-pause")
            icon.addClass("icon-play")
            visualizer.pause()

    refresh = ->
        refreshsource.getMessages()

    # Auth
    checkSession = ->
        auth.activeSession (data)->
            if (data)
                isSignedIn(data)
            else
                isSignedOut()

    isSignedIn = (data)->
        $(document.body).addClass('signedIn')
        userText = $(".navbar-text", signOut)
        userText.html(nano(userText.data("text"), data))
        signIn.addClass("hidden")
        signOut.removeClass("hidden")
        if settings
            rigSearchBox(settings)
            twitterFontana(transition: "scroll-down",
                           $("#search", settings).val())
        else
            twitterFontana(transition: "scroll-down",
                           'moocnantes')

    isSignedOut = ->
        $(document.body).removeClass('signedIn')
        signIn.removeClass("hidden")
        signOut.addClass("hidden")
        if settings
            rigSearchBox(settings)
            HTMLFontana(transition: "scroll-down")
        else
            HTMLFontana()

    # Two Demo Fontanas
    twitterFontana = (settings={}, q="moocnantes")->
        if visualizer
            visualizer.stop()
        datasource = new Fontana.datasources.ProxyTwitterSearch(q, '/all')
        refreshsource = new Fontana.datasources.TwitterSearch(q)
        visualizer = new Fontana.Visualizer(container, datasource)
        visualizer.start(settings)

    # Automatically refresh /all db. If the admin page is not
    # displayed, the /moderated stream will not refresh.
    fetchMessages = ->
        refresh()
        scheduleFetchMessages()

    scheduleFetchMessages = ->
        fetchMessagesTimer = setTimeout((=> fetchMessages()), 60000)

    refresh()

    HTMLFontana = (settings={})->
        if visualizer
            visualizer.stop()
        if not settings.transition
            settings.transition = ''
        visualizer = new Fontana.Visualizer(container, HTMLFontana.datasource)
        visualizer.start(settings)
    # Prepare our datasource, the messages will disappear soon...
    HTMLFontana.datasource = new Fontana.datasources.HTML(container)
    HTMLFontana.datasource.getMessages()
    scheduleFetchMessages()

    # Bindings
    $(".settings", controls).click -> toggleSettings.call(this)
    $(".pause-resume", controls).click -> toggleViz.call(this)
    $(".fullscreen", controls).click -> refresh.call(this)
    $("button", signIn).click -> auth.signIn(checkSession)
    $("button", signOut).click -> auth.signOut(checkSession)
    $("#logos .close").click -> $(this).parent().remove()

    checkSession()
