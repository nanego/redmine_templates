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
                "description_sections_fields",
                "add_section_button"
            ];
        }

        connect() {
            this.toggleDescriptionSectionsField();
        }

        toggleDescriptionSectionsField() {
            if (this.split_description_checkboxTarget.checked) {
                this.description_fieldTarget.style.display = "none";
                this.description_sections_fieldsTarget.style.display = "block";
                this.add_section_buttonTarget.style.display = "block";
            } else {
                this.description_fieldTarget.style.display = "block";
                this.description_sections_fieldsTarget.style.display = "none";
                this.add_section_buttonTarget.style.display = "none";
            }
        }

        addSection(e) {
            let sections = this.description_sections_fieldsTarget.querySelectorAll(".split_description_section");
            let template = sections[0].outerHTML;
            let index = sections.length

            template = this.updateSectionId(template, index);
            this.description_sections_fieldsTarget.insertAdjacentHTML("beforeend", template);
            this.emptyNewSectionValues(this.description_sections_fieldsTarget.lastChild);
            this.createWikiToolBar(this.description_sections_fieldsTarget.lastChild);
        }

        updateSectionId(template, index) {
            template = template.replace(/\_0\_/g, "_" + index + "_").replace(/\[0\]/g, "[" + index + "]");
            template = template.replace("Description section 1", "Description section " +  (index + 1));

            return template;
        }

        emptyNewSectionValues(section) {
            section.querySelector("textarea").value = "";
            section.querySelectorAll("input[type=text]").forEach(input => input.value = "");
        }

        createWikiToolBar(section) {
            let description_field = section.querySelector("textarea");
            section.querySelector("p:nth-child(3)").appendChild(description_field);

            this.cleanSectionFromOldWikitoolbar(section);
            this.addWikiToolBar(description_field.id);
        }

        cleanSectionFromOldWikitoolbar(section) {
            section.querySelector(".jstBlock").remove();
            section.querySelector("script").remove();
            section.querySelector("p:nth-child(4)").remove();
        }

        addWikiToolBar(field_id) {
            var wikiToolbar = new jsToolBar(document.getElementById(field_id));
            wikiToolbar.setHelpLink("/help/fr/wiki_syntax_textile.html");
            wikiToolbar.setPreviewUrl("/preview/text");
            wikiToolbar.draw();
        }
    });

    stimulus_application.register("section-form", class extends Stimulus.Controller {

        static get targets() {
            return [
                "destroy_hidden"
            ];
        }

        connect() {}

        deleteSection(e) {
            if (window.confirm("Êtes-vous sûr ?")) {
                this.element.style.display = "none";
                this.destroy_hiddenTarget.value = "1";
            }
        }
    });
})();
