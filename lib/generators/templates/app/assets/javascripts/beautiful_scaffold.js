$(document).ready(function(){

  /* Menu */
  $(".menuelt").click(function(){
    $(".menuelt").removeClass("active");
    $(this).addClass("active");

    idsubmenu = $(this).attr('data-id');
    $(".submenu").addClass("hidden");
    $("#"+idsubmenu).removeClass("hidden");
  });

  /* Box */
  $(".box-title").click(function(){
    p = $(this).parent();
    if(p.hasClass("close")){
      p.removeClass("close",500)
    }else{
      p.addClass("close",500)
    }
  });

  /* Flash */
  $("#flash-warning,#flash-notice,#flash-success,#flash-error").click(function(){
    $(this).fadeOut(1000, function(){
      $(this).remove();
    });
  });

  /* Richtext editor */
  $('.select-richtext').click(function(){
    $('.label-richtext-type[for=' + $(this).attr('id') + ']').trigger('click');
  });
  $('.label-richtext-type').live("click", function(){
    elt = $('#' + $(this).attr('for'));
    newSet = elt.val();
    idspleditor = elt.attr('data-spleditor');
    ideditor = elt.attr('data-editor');
    $('#' + idspleditor).markItUpRemove();
    if(!$('#' + idspleditor).hasClass('markItUpEditor')){
      switch(newSet) {
        case 'bbcode':
          $('#' + idspleditor).markItUp(myBbcodeSettings);
          break;
        case 'wiki':
          $('#' + idspleditor).markItUp(myWikiSettings);
          break;
        case 'textile':
          $('#' + idspleditor).markItUp(myTextileSettings);
          break;
        case 'markdown':
          $('#' + idspleditor).markItUp(myMarkdownSettings);
          break;
        case 'html':
          $('#' + idspleditor).markItUp(myHtmlSettings);
          break;
      }
    }
    $('#' + ideditor).removeClass("bbcode html markdown textile wiki").addClass(newSet);
    return true;
  });
});

$(function(){
  try{
    /* PJAX initializer */
    $('a:not(.nopjax)').pjax('#pjax-container').live('click');
    $('#pjax-container').bind('pjax:start', function() { 
      $('.loader').show();
      $("#flash-warning,#flash-notice,#flash-success,#flash-error").fadeOut(1000, function(){
        $("#flash-warning,#flash-notice,#flash-success,#flash-error").remove();
      }); 
    }).bind('pjax:end',   function() { $('.loader').hide() })
      .bind('pjax:timeout', function() { $('.loader').show();return false; });
  }
  catch(err)
  {
    //Handle errors here
  }
});