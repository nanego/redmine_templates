$(document).ready(function() {

    // New issue template button at the bottom of the new issue form
    $("a#init_issue_template").on("click", function(event){
        event.preventDefault();
        $('#issue-form').attr('action', $(this).attr('data-href') );
        $("#issue-form").submit();
    });

    $('#select_issue_template').on('change', function() {
        $('#form-select-issue-template').submit();
    });

});