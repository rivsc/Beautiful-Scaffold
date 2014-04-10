function modify_dom_init(){
    var span2 = $("body>div.container-fluid>div.row>div.col-md-2");
    span2.addClass("fixed visible-md visible-lg");
    span2.removeClass("col-md-2");

    span2.children("ul").removeClass("well");

    var span10 = $("body>div.container-fluid>div.row>div.col-md-10");
    span10.addClass("filler");
    span10.removeClass("col-md-10");

    var cnt2 = $("body>div.container-fluid").contents();
    $("body>div.container-fluid").replaceWith(cnt2);

    var cnt = $("body>div.row").contents();
    $("body>div.row").replaceWith(cnt);

    $('body').show();
    $('body').css('display','block'); /* Hack Firefox previous line dosen't work with firefox */
}