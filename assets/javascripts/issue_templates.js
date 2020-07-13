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
            return [
                "custom_form_radio_button",
                "custom_form_path_text_field",
                "custom_form",
                "standard_form",
                "split_description"
            ];
        }

        connect() {
            this.toogleForm()
        }

        reloadForm(e) {
            console.log(e.currentTarget.value);

            fetch('/issue_templates/custom_form?path=' + e.currentTarget.value)
                .then(response => response.text())
                .then(html => {
                    $('#custom_form_container')[0].innerHTML = html
                });
        }

        toogleForm() {
            if (this.custom_form_radio_buttonTarget.checked) {
                this.custom_form_path_text_fieldTarget.parentNode.style.display = 'block';
                this.custom_formTarget.style.display = 'block';
                this.standard_formTarget.style.display = 'none';
                this.split_descriptionTarget.style.display = 'none';
            } else {
                this.custom_form_path_text_fieldTarget.parentNode.style.display = 'none';
                this.custom_formTarget.style.display = 'none';
                this.standard_formTarget.style.display = 'block';
                this.split_descriptionTarget.style.display = 'block';
            }
        }

    })

    stimulus_application.register("split-description", class extends Stimulus.Controller {

        static get targets() {
            return [
                "split_description_checkbox",
                "description_field",
                "description_fields",
                "add_buttons",
                "section_template",
                "instruction_template"
            ];
        }

        connect() {
            this.toggleDescriptionField();
        }

        toggleDescriptionField() {
            if (this.split_description_checkboxTarget.checked) {
                this.description_fieldTarget.style.display = "none";
                this.description_fieldsTarget.style.display = "block";
                this.add_buttonsTarget.style.display = "block";
            } else {
                this.description_fieldTarget.style.display = "block";
                this.description_fieldsTarget.style.display = "none";
                this.add_buttonsTarget.style.display = "none";
            }
        }

        addSection(e) {
            let index = this.description_fieldsTarget.querySelectorAll(".split_description:not(.template)").length;
            let template = this.section_templateTarget.outerHTML;

            this.appendItem(template.replace(/\$id_section\$/g, index));
        }

        addInstruction(e) {
            let index = this.description_fieldsTarget.querySelectorAll(".split_description:not(.template)").length;
            let template = this.instruction_templateTarget.outerHTML;

            this.appendItem(template.replace(/\$id_instruction\$/g, index));
        }

        appendItem(item) {
            this.description_fieldsTarget.insertAdjacentHTML("beforeend", item);
            this.cleanTemplate(this.description_fieldsTarget.lastChild);
            this.createWikiToolBar(this.description_fieldsTarget.lastChild);
        }

        cleanTemplate(item) {
            item.classList.remove("template");
            item.style.display = "block";
        }

        createWikiToolBar(item) {
            let text_area = item.querySelector("textarea");
            item.querySelector("p.with-textarea").appendChild(text_area);

            this.cleanOldWikitoolbar(item);
            this.addWikiToolBar(text_area.id);
        }

        cleanOldWikitoolbar(item) {
            item.querySelector(".jstBlock").remove();
            item.querySelector("script").remove();
            item.querySelector("p:empty").remove();
        }

        addWikiToolBar(field_id) {
            var wikiToolbar = new jsToolBar(document.getElementById(field_id));
            wikiToolbar.setHelpLink("/help/fr/wiki_syntax_textile.html");
            wikiToolbar.setPreviewUrl("/preview/text");
            wikiToolbar.draw();

            if (typeof initRedmineWysiwygEditor === "function") {
                this.launchWysiwygEditor();
            }
        }

        launchWysiwygEditor() {
            $(".jstEditor:last").each(initRedmineWysiwygEditor);

            $(document).ajaxSuccess(function() {
                $(".jstEditor:last").each(initRedmineWysiwygEditor);
            });

            // Redmine 4.1+
            $(document).on("ajax:success", function() {
                $(".jstEditor:last").each(initRedmineWysiwygEditor);
            });
        }
    });

    stimulus_application.register("description-item-form", class extends Stimulus.Controller {

        static get targets() {
            return [
                "destroy_hidden"
            ];
        }

        connect() {}

        delete(e) {
            if (window.confirm("Êtes-vous sûr ?")) {
                this.element.style.display = "none";
                this.destroy_hiddenTarget.value = "1";
            }
        }
    });
})();
