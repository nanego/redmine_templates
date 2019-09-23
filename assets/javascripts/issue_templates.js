// Can't use Rails' remote select because we need the form data
function updateIssueTemplateFrom(url) {
    $.ajax({
        url: url,
        type: 'put',
        data: $('#issue-template-form').serialize()
    });
}

$(document).ready(function ($) {
    $(".list_templates_projects_names").hover(function () {
        var className = $(this).attr('class').split(' ')[0]; // get first class
        $('.' + className).toggleClass("hover");
    });


});

// Template Form controller
(function () {
    stimulus_application.register("template-form", class extends Stimulus.Controller {

        static get targets() {
            return ["custom_form_radio_button", "custom_form_path_text_field"]
        }

        // initialize()

        connect() {
            // this.load()
            this.toogleForm()
        }

        load(url, container) {
            fetch(url)
                .then(response => response.text())
                .then(html => {
                    container.innerHTML = html
                })
        }

        toogleForm() {
            if (this.custom_form_radio_buttonTarget.checked) {
                this.custom_form_path_text_fieldTarget.parentNode.style.display = 'none';
            } else {
                this.custom_form_path_text_fieldTarget.parentNode.style.display = 'block';
            }
        }
    })
})();


