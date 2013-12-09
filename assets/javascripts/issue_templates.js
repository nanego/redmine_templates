// Can't use Rails' remote select because we need the form data
function updateIssueTemplateFrom(url) {
    $.ajax({
        url: url,
        type: 'post',
        data: $('#issue-template-form').serialize()
    });
}
