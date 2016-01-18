/**
 * Created by jscott on 1/1/16.
 * Refs: https://github.com/rweng/jquery-datatables-rails
 *       http://api.jquery.com/jQuery.getJSON/
 *       http://getbootstrap.com/components/#panels
 *       http://datatables.net
 */


var accessibleUrl,
    userTable,
    accessTable,
    contentTable,
    accessibleTable;

/**
 * Content/Access Profile Table Selection
 * - fire ajax to get data, using url on accessible-table tbody
 * - then update accessible-table rows
 */
function profileTablesRequester(ev) {
    var dataPackage = $(ev.currentTarget).data().package,
        contentType = dataPackage.hasOwnProperty('resource_options'), // then AccessProfile
        dataResponse;

    /* flag selected in content table */
    $("table.profile tbody tr").removeClass('success');
    $(ev.currentTarget).addClass('success');

    $.ajax({
        headers: {'X-CSRF-Token': csrfToken, 'X-XSRF-Token': csrfToken },
        method: "GET",
        dataType: "json",
        contentType: 'json',
        url: $("#accessible-table tbody").data().accessibleUrl, // accessibleUrl,
        data: dataPackage,
        accepts: 'json'
    }).done(function(data,textStatus) {
            dataResponse = data.package;
            replaceAccessibleTableRows(dataResponse);
            console.log( "profileTablesRequester("+ contentType ? 'AccessProfile': 'ContentProfile' + ") success: " + textStatus + ", Response=" + JSON.stringify(dataResponse));
      }).fail(function(jqXHR, textStatus, errorThrown) {
            accessibleTable.clear().draw();
            console.log( "profileTablesRequester("+ contentType ? 'AccessProfile': 'ContentProfile' + ") error: " + textStatus + ', thrown=' + errorThrown + ', RequestPkg=' + JSON.stringify(dataPackage));
      });

    return false;
}


/**
 * Reloads the content-table with supplied rows from a contentProfile package
 * @param dataPackage {contentProfile}
 */
function replaceContentTableRows(dataPackage) {
    var tTitle = $('#content-title'),
            vList = dataPackage.package[1].content_profile.entries,
            newRow = [],
            counter = 0,
            trNode,
            trRow;

    tTitle.html(dataPackage.package[1].message);
    if (dataPackage.package[1].success) {

        contentTable.rows().remove().draw();

        $.each(vList, function(index, row) {
            newRow = [];
            newRow.push('<td>' + row.description  + '</td>');
            newRow.push('<td>' + row.content_type  + '</td>');
            newRow.push('<td>' + row.content_type_description  + '</td>');
            newRow.push('<td>' + row.topic_type  + '</td>');
            newRow.push('<td>' + row.topic_value  + '</td>');
            newRow.push('<td>' + JSON.stringify(row.content_value)  + '</td>');
            trRow = $('<tr>').append(newRow.join());

            trNode = contentTable.row.add(trRow).draw().node();
            $(trNode).data('package', row).on( "click", profileTablesRequester);
            counter = index + 1;
        });
    } else {
        contentTable.rows().remove().draw();
        accessibleTable.rows().remove().draw();
    }

    consoleLog('replaceContentTableRows(rowsAdded=' + counter + ')');
    return false;
}

/**
 * Reloads the access-table with supplied rows from a accessProfile package
 * @param dataPackage {accessProfile}
 */
function replaceAccessTableRows(dataPackage) {
    var tTitle = $('#access-title'),
            vList = dataPackage.package[0].access_profile.entries,
            newRow = [],
            counter = 0,
            trNode,
            trRow;

    tTitle.html(dataPackage.package[0].message);
    if (dataPackage.package[0].success) {
        accessTable.clear().draw();

        $.each(vList, function(index, row) {
            newRow = [];
            newRow.push('<td>' + row.description  + '</td>');
            newRow.push('<td>' + row.content_type  + '</td>');
            newRow.push('<td>' + row.content_type_description  + '</td>');
            newRow.push('<td>' + row.topic_type  + '</td>');
            newRow.push('<td>' + row.topic_value  + '</td>');
            newRow.push('<td>' + JSON.stringify(row.content_value)  + '</td>');
            trRow = $('<tr>').append(newRow.join());

            trNode = accessTable.row.add(trRow).draw().node();
            $(trNode).data('package', row).on( "click", profileTablesRequester);
            counter = index + 1;
        });
    } else {
        accessTable.clear().draw();
        accessibleTable.clear().draw();
    }

    consoleLog('replaceAccessTableRows(rowsAdded=' + counter + ')');
    return false;
}

/**
 * Reloads the accessible-table with supplied rows from a Profile package
 * @param dataPackage {ProfileEntry}
 *
 * dataPackage = {success: true, message: "", content: 'access',
 *                username: pg_u.username, display_name: pg_u.display_name ,
 *                package: [
 *                  {source: "datafiles", filename: "someFile.dat", created: '12/1/2015', size: "0"},
 *                  ...
 *                         ]
 *                }
 */
function replaceAccessibleTableRows(dataPackage) {
    var tTitle = $('#accessible-title'),
            vList = dataPackage.package,
            newRow = [],
            counter = 0,
            trNode,
            trRow;

    tTitle.html(dataPackage.message);
    if (dataPackage.success) {
        accessibleTable.clear().draw();
        $.each(vList, function(index, row) {
                    newRow = [];
                    newRow.push('<td>' + row.filename  + '</td>');
                    newRow.push('<td>' + row.source  + '</td>');
                    newRow.push('<td>' + row.created  + '</td>');
                    newRow.push('<td>' + row.size  + '</td>');
                    trRow = $('<tr>').append(newRow.join());

                    trNode = accessibleTable.row.add(trRow).draw().node();
                    $(trNode).data('package', row); // .on( "click", profileTablesRequester);
                    counter = index + 1;
        });
    } else {
        accessibleTable.clear().draw();
        $("table.profile tbody tr").removeClass('success');
    }

    consoleLog('replaceAccessibleTableRows(rowsAdded=' + counter + ')');
    return false;
}

/**
 * Initialization Routine for Demo Pages
 * @returns {boolean}
 */
function handleDemoPages() {

    accessTable = $('#access-table').DataTable({
        language: {
            emptyTable: "Please make a choice from the Users table on the left."
        }
    });

    contentTable = $('#content-table').DataTable({
        language: {
            emptyTable: "Please make a choice from the Users table on the left."
        }
    });

    accessibleTable = $('#accessible-table').DataTable({
        language: {
            emptyTable: "Please make a choice from content table above."
        }
    });

    userTable = $('#users-table').DataTable({
        scrollY: "620px",
        language: {
            emptyTable: "No User Available!"
        }
    });


    /**
     *  Activate the UI, Track clicks from UsersTable to control both pages
     */
    var userRows = $('#users-table tbody tr');

    userRows.on('click', function (event) {
        var dataPackage = $(event.currentTarget).data().package;
//            contentType = dataPackage.package.hasOwnProperty('access_profile');

        /* save url to fetch accessible files from */
        accessibleUrl = $("#accessible-table tbody").data().accessibleUrl;

        /*
         Initialize Title on Accessible Content Table
         */
        $('#accessible-title').
                html('Accessible Content for ' + dataPackage.username + ":" + dataPackage.display_name);

        /* maintain accessibleTable's state */
        accessibleTable.clear().draw();

        /* maintain selected item on users table */
        userRows.removeClass('success');
        $(event.currentTarget).addClass('success');

        /* Determine which page we are on and use that table loader */
        replaceAccessTableRows(dataPackage);
        replaceContentTableRows(dataPackage);

        consoleLog(dataPackage.username + " Selected." + JSON.stringify(dataPackage));
    });

    /* choose first one to start things off */
    userRows.first().click();

    return true;
} // end function

/* ********************************************************
 * JQuery Enabled Processing
 * ********************************************************
 */
$(function() {

    /* Only for the proper page */
    if ( controllerName.startsWith('profile') ) {
        /*
         * Initial Establish the dataTables
         */
        try {
            $.extend($.fn.dataTable.defaults, {
                dom: "fti",
                colReorder: false,
                fixedColumns: false,
                fixedHeader: false,
                autoWidth: true,
                paging: false,
                searching: true,
                scrollY: "420px",
                scrollCollapse: true,
                scroller: true,
                responsive: true,
                select: {
                    selector: "tr",
                    style: "single",
                    items: "row",
                    info: true
                }
            });
        } catch(e) {
            consoleLog("Defaults Failed " + e);
        }
        handleDemoPages();
    }

});

