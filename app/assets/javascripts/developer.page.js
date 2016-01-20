/**
 * Created by jscott on 1/1/16.
 * Refs: https://github.com/rweng/jquery-datatables-rails
 *       http://api.jquery.com/jQuery.getJSON/
 *       http://getbootstrap.com/components/#panels
 *       http://datatables.net
 */


/**
 * Collect portion of RouteInfo
 */
function handleRailsInfo(ev) {
    var pkg = $(ev.currentTarget).data(),
        dataResponse;

    console.log( "handleRailsInfo() init: " + JSON.stringify(pkg));

    $.ajax({
        headers: {'X-CSRF-Token': csrfToken, 'X-XSRF-Token': csrfToken },
        method: "GET",
        url: '/' + pkg.url
    }).done(function(data,textStatus, jqXHR) {
            dataResponse = $(jqXHR.responseText); //.find('body').contents();
            if (pkg.header.startsWith('#about')) {
                $(pkg.header).empty().append('<h2>Properties</h2>').addClass('show');
            } else {
                $(pkg.header).remove();
            }
            $(pkg.place).html( dataResponse ).fadeIn().addClass('show');

            console.log( "handleRailsInfo() success: " + textStatus + ", Response=" + dataResponse);
      }).fail(function(jqXHR, textStatus, errorThrown) {
            console.log( "handleRailsInfo() error: " + textStatus + ', thrown=' + errorThrown + ', Parms=' + JSON.stringify(pkg));
            $(pkg.place).addClass('hidden');
      });

    return false;
}

/* ********************************************************
 * JQuery Enabled Processing
 * ********************************************************
 */
$(function() {

    /* Only for the proper page */
    if ( controllerAction.startsWith('details_sysinfo') ) {
        /*
         * Initial Establish sections
         * id="about" -  <a href="rails/info/properties" onclick="getRailsInfo('about-content'); return false;">
         *     target: <div id="about-content" style="display: none"></div>
         * id="routes" - <a href="rails/info/routes" onclick="getRailsInfo('route-content'); return false;">
         *     target: <div id="route-content" style="display: none"></div>
         */
        $('h2 > a.btn-lg').on('click', handleRailsInfo);
    }

});

