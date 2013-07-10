function modify_dom_init(){
    var span2 = $("body>div.container-fluid>div.row-fluid>div.span2");
    span2.addClass("fixed visible-desktop");
    span2.removeClass("span2");

    span2.children("ul").removeClass("well");

    var span10 = $("body>div.container-fluid>div.row-fluid>div.span10");
    span10.addClass("filler");
    span10.removeClass("span10");

    var cnt2 = $("body>div.container-fluid").contents();
    $("body>div.container-fluid").replaceWith(cnt2);

    var cnt = $("body>div.row-fluid").contents();
    $("body>div.row-fluid").replaceWith(cnt);

    $('body').show();
    $('body').css('display','block'); /* Hack Firefox previous line dosen't work with firefox */
}