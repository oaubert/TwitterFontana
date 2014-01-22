# Bootswatch stylesheets
styles =
    TwitterFontana:
        stylesheet: "/css/fontana.css"
        description: "TwitterFontana's default style"
    Bootstrap:
        stylesheet: ""
        description: "Just plain bootstrap"
    Amelia:
        stylesheet: "/bootstrap/amelia/bootstrap.min.css"
        description: "Sweet and cheery"
    Cerulean:
        stylesheet: "/bootstrap/cerulean/bootstrap.min.css"
        description: "A calm blue sky"
    Cosmo:
        stylesheet: "/bootstrap/cosmo/bootstrap.min.css"
        description: "An ode to Metro"
    Cyborg:
        stylesheet: "/bootstrap/cyborg/bootstrap.min.css"
        description: "Jet black and electric blue"
    Flatly:
        stylesheet: "/bootstrap/flatly/bootstrap.min.css"
        description: "Flat and modern"
    Journal:
        stylesheet: "/bootstrap/journal/bootstrap.min.css"
        description: "Crisp like a new sheet of paper"
    Readable:
        stylesheet: "/bootstrap/readable/bootstrap.min.css"
        description: "Optimized for legibility"
    Simplex:
        stylesheet: "/bootstrap/simplex/bootstrap.min.css"
        description: "Mini and minimalist"
    Slate:
        stylesheet: "/bootstrap/slate/bootstrap.min.css"
        description: "Shades of gunmetal gray"
    Spacelab:
        stylesheet: "/bootstrap/spacelab/bootstrap.min.css"
        description: "Silvery and sleek"
    United:
        stylesheet: "/bootstrap/united/bootstrap.min.css"
        description: "Ubuntu orange and unique font"

transitions =
    "Compress": "compress"
    "Fade-In": "fade-in"
    "Hinge": "hinge"
    "Lightspeed": "lightspeed"
    "Scroll-Down": "scroll-down"
    "Scroll-Up": "scroll-up"
    "Slide": "slide"
    "Tilt-Scroll": "tilt-scroll"
    "Vertigo": "vertigo"
    "Zoom-In": "zoom-in"

# Tying things together to make the demo page work
$ ->
    controls = $("#controls")
    signIn = $("#signin")
    signOut = $("#signout")
    container = $(".fontana")
    visualizer = null
    settings = null

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

    toggleFullscreen = ->
        if Fontana.utils.isFullScreen()
            Fontana.utils.cancelFullScreen()
        else
            Fontana.utils.requestFullScreen(document.body)

    # Two Demo Fontanas
    twitterFontana = (settings={}, q="mooc")->
        if visualizer
            visualizer.stop()
        datasource = new Fontana.datasources.ProxyTwitterSearch(q, '/moderated')
        visualizer = new Fontana.Visualizer(container, datasource)
        visualizer.start(settings)

    HTMLFontana = (settings={})->
        if visualizer
            visualizer.stop()
        if not settings.transition
            settings.transition = 'scroll-down'
        visualizer = new Fontana.Visualizer(container, HTMLFontana.datasource)
        visualizer.start(settings)
    # Prepare our datasource, the messages will disappear soon...
    HTMLFontana.datasource = new Fontana.datasources.HTML(container)
    HTMLFontana.datasource.getMessages()

    # Bindings
    $(".settings", controls).click -> toggleSettings.call(this)
    $(".pause-resume", controls).click -> toggleViz.call(this)
    $(".fullscreen", controls).click -> toggleFullscreen.call(this)
    $("button", signIn).click -> auth.signIn(checkSession)
    $("button", signOut).click -> auth.signOut(checkSession)
    $("#logos .close").click -> $(this).parent().remove()

    twitterFontana(transition: "scroll-down", 'moocnantes')
