var Fontana = window.Fontana || {};

Fontana.utils = (function () {
    var prettyDate, requestFullscreen, exitFullscreen, vendors;

    prettyDate = function (time) {
        var date = new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," ")),
            diff = (((new Date()).getTime() - date.getTime()) / 1000),
            day_diff = Math.floor(diff / 86400);

        if ( isNaN(day_diff) || day_diff < 0 || day_diff >= 31 )
            return;

        return day_diff == 0 && (
            diff < 60 && "just now" ||
                diff < 120 && "1 minute ago" ||
                diff < 3600 && Math.floor( diff / 60 ) + " minutes ago" ||
                diff < 7200 && "1 hour ago" ||
                diff < 86400 && Math.floor( diff / 3600 ) + " hours ago") ||
            day_diff == 1 && "Yesterday" ||
            day_diff < 7 && day_diff + " days ago" ||
            day_diff < 31 && Math.ceil( day_diff / 7 ) + " weeks ago";
    }

    vendors = ["webkit", "moz", "o", "ms"];

    requestFullscreen = function (el) {
        var request = el.requestFullscreen;
        $.each(vendors, function (i, vendor) {
            if (request) return false;
            request = el[vendor + "RequestFullScreen"];
        });
        if (request) {
            request.call(el);
        }
        else if (typeof window.ActiveXObject !== "undefined") { // Older IE.
            var wscript = new ActiveXObject("WScript.Shell");
            if (wscript !== null) {
                wscript.SendKeys("{F11}");
            }
        }
    }

    exitFullscreen = function () {
        var request = document.exitFullscreen;
        for (vendor in vendors) {
            if (request) break;
            request = el[vendor + "CancelFullScreen"];
        }
        if (request) {
            request();
        }
    }

    return {
        'prettyDate': prettyDate,
        'requestFullscreen': requestFullscreen,
        'exitFullscreen': exitFullscreen
    }
}());
