// Can't use Rails' remote select because we need the form data
function updateIssueTemplateFrom(url) {
    $.ajax({
        url: url,
        type: 'post',
        data: $('#issue-template-form').serialize()
    });
}

$(document).ready(function($) {
    $(".list_templates_projects_names").hover(function () {
        var className = $(this).attr('class').split(' ')[0]; // get first class
        $('.' + className).toggleClass("hover");
    });


});

