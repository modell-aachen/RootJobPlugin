jQuery(function($) {
    $('.RootJobPluginForm').submit(function() {
        var $form = $(this);
        $.blockUI();
        $.post($form.attr('action'), $form.serialize(), 'text').
            done(function(data, textStatus, xhr) {
                alert(data);
            }).
            fail(function(xhr, textStatus, errorThrown) {
                alert(errorThrown);
            }).always(function() {
                $.unblockUI();
            });
        return false;
    });
});
