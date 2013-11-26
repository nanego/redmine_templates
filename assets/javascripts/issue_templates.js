$(document).ready(function() {

    // New issue template button at the bottom of the new issue form
    $("a#init_issue_template").on("click", function(event){
        event.preventDefault();
        $('#issue-form').attr('action', $(this).attr('data-href') );
        $("#issue-form").submit();
    });

    $('#select_issue_template').on('change', function() {
        if ($(this).val().indexOf("issue_templates") > -1) {
            window.location.href=$(this).val(); // Click on "Manage templates"
        }else{
            $('#form-select-issue-template').submit();
        };
    });

});

// Can't use Rails' remote select because we need the form data
function updateIssueTemplateFrom(url) {
    $.ajax({
        url: url,
        type: 'post',
        data: $('#issue-template-form').serialize()
    });
}