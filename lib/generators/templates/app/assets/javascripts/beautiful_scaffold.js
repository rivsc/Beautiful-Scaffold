$(document).ready(function(){

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
        $('a:not(.nopjax)').live('click', function(){
            /* Work on all bootstrap navbar */
            $(this).parent().parent().find('.active').removeClass('active');
            $(this).parent().addClass('active');
        });
        $('#pjax-container').bind('pjax:start', function() {
            $('.loader').show();
        }).bind('pjax:end',   function() {
            $('.loader').hide();
        }).bind('pjax:timeout', function() { $('.loader').show();return false; });
    }
    catch(err)
    {
        //Handle errors here
    }
});