// Can't use Rails' remote select because we need the form data
function updateIssueTemplateFrom(url) {
    $.ajax({
        url: url,
        type: 'put',
        data: $('#issue-template-form').serialize()
    });
}

(function ($) {
    $.fn.positionedFormGroups = function (sortableOptions, options) {
        var sortable = this.sortable($.extend({
            placeholder: "ui-state-highlight",
            axis: 'y',
            handle: ".sort-handle-section_group",
            start: function(e,ui){
                ui.placeholder.height(ui.helper.outerHeight());
            }
        }, sortableOptions)).disableSelection();

        this.on("sortupdate", function (event, ui) {
            var sortable = $(this);
            var position = 1;

            sortable.children(".split_description.section_group:not(.template)").each(function () {
                $(this).find("input[name*=position]:first").attr("value", position);
                position += 1;
            });
        });

        return sortable;
    }
    $.fn.positionedFormItems = function (sortableOptions, options) {
        var sortable = this.sortable($.extend({
            placeholder: "ui-state-highlight",
            axis: 'y',
            handle: ".sort-handle",
            start: function(e,ui){
                ui.placeholder.height(ui.helper.outerHeight());
            }
        }, sortableOptions)).disableSelection();

        this.on("sortupdate", function (event, ui) {
            var sortable = $(this);
            var position = 1;

            sortable.children(".split_description:not(.template)").each(function () {
                $(this).find("input[name*=position]:first").attr("value", position);
                position += 1;
            });
        });

        return sortable;
    }
}(jQuery));

$(document).ready(function ($) {
    $(".list_templates_projects_names").hover(function () {
        var className = $(this).attr('class').split(' ')[0]; // get first class
        $('.' + className).toggleClass("hover");
    });

    $("#split-description-groups").positionedFormGroups()
    $("#split-description-groups .sections").positionedFormItems()
});

function applySelect2ToSelects() {
    if ((typeof $().select2) === 'function') {
        $('.split_description.select select:visible').filter(function() {
            return !$(this).hasClass('classic-select');
        }).select2({
            tags: true,
            tokenSeparators: [';'],
            containerCss: {
                width: '400px',
                minwidth: '400px'
            },
            width: '400px'
        });
    }
}

function makeListsSortable() {
    $(".possible-values ul").sortable({
        axis: "y",
        beforeStop: function (event) {
            let ul = $(event.target).closest('ul')
            resetHiddenFields(ul)
        }
    })
}

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
                "section_groups_fields",
                "template_sections",
                "select_new_section_type",
                "section_group_template"
            ];
        }

        connect() {
            this.toggleDescriptionField()
        }

        toggleDescriptionField() {
            if (this.split_description_checkboxTarget.checked) {
                this.description_fieldTarget.style.display = "none";
                this.template_sectionsTarget.style.display = "block";
            } else {
                this.description_fieldTarget.style.display = "block";
                this.template_sectionsTarget.style.display = "none";
            }
        }

        addSectionsGroup(e) {
            e.preventDefault()
            let index = this.section_groups_fieldsTarget.querySelectorAll(".split_description.section_group:not(.template)").length
            let template = this.section_group_templateTarget.outerHTML
            if (template != undefined) {
                this.appendGroupItem(template.replace(/\$id_group_section\$/g, index))
            }
        }

        addSection(e) {
            e.preventDefault();
            let sectionGroupElement = e.target.closest(".section_group")
            let sectionsElement = sectionGroupElement.querySelector(".sections")
            let select_new_section_typeElement = sectionGroupElement.querySelector(".select_new_section_type")
            let index = sectionsElement.querySelectorAll(".split_description:not(.template)").length
            let template
            switch (select_new_section_typeElement.value) {
                case('1'):
                    template = sectionGroupElement.querySelector(".split_description.template.section").outerHTML
                    break
                case('2'):
                    template = sectionGroupElement.querySelector(".split_description.template.instruction").outerHTML
                    break
                case('3'):
                    template = sectionGroupElement.querySelector(".split_description.template.field").outerHTML
                    break
                case('4'):
                    template = sectionGroupElement.querySelector(".split_description.template.checkbox").outerHTML
                    break
                case('5'):
                    template = sectionGroupElement.querySelector(".split_description.template.date").outerHTML
                    break
                case('6'):
                    template = sectionGroupElement.querySelector(".split_description.template.numeric").outerHTML
                    break 
                case('7'):
                    template = sectionGroupElement.querySelector(".split_description.template.select").outerHTML
                    break
            }
            if (template != undefined) {
                this.appendItem(template.replace(/\$id_section\$/g, index), sectionsElement)
            }
        }

        appendGroupItem(item) {
            this.section_groups_fieldsTarget.insertAdjacentHTML("beforeend", item)
            this.cleanTemplate(this.section_groups_fieldsTarget.lastChild)
            this.createWikiToolBar(this.section_groups_fieldsTarget.lastChild)
            $("#split-description-groups").trigger("sortupdate")
            applySelect2ToSelects()
            makeListsSortable()
        }

        appendItem(item, sectionsElement) {
            sectionsElement.insertAdjacentHTML("beforeend", item)
            this.cleanTemplate(sectionsElement.lastChild)
            this.createWikiToolBar(sectionsElement.lastChild)
            $(sectionsElement).trigger("sortupdate")
            applySelect2ToSelects()
            makeListsSortable()
        }

        cleanTemplate(item) {
            item.classList.remove("template");
            item.style.display = "block";
        }

        createWikiToolBar(item) {
            let text_area = item.querySelector("textarea")
            if (text_area) {
                item.querySelector("p.with-textarea").appendChild(text_area);
                this.cleanOldWikitoolbar(item);
                this.addWikiToolBar(text_area);
            }
        }

        cleanOldWikitoolbar(item) {
            if (item.querySelector(".jstBlock")) {
                item.querySelector(".jstBlock").remove();
            }
            if (item.querySelector("script")) {
                item.querySelector("script").remove();
            }
            if (item.querySelector("p:empty")) {
                item.querySelector("p:empty").remove();
            }
        }

        addWikiToolBar(field) {
            var wikiToolbar = new jsToolBar(field);
            wikiToolbar.setHelpLink(field.dataset.helpLink);
            wikiToolbar.setPreviewUrl(field.dataset.previewLink);
            wikiToolbar.draw();

            if (typeof RedmineWysiwygEditorManager === "function") {
                this.launchWysiwygEditor();
            }
        }

        launchWysiwygEditor() {
            let redmineWysiwygEditorManager = new RedmineWysiwygEditorManager();

            $(function() {
                redmineWysiwygEditorManager.update();

                $(document).ajaxSuccess(function (event, jqXHR, ajaxSettings, thrownError) {
                    redmineWysiwygEditorManager.update();
                });

                // Redmine 4.1+
                $(document).on('ajax:success', function (event) {
                    redmineWysiwygEditorManager.update();
                });
            });
        }
    });

    stimulus_application.register("description-item-form", class extends Stimulus.Controller {

        static get targets() {
            return [
                "destroy_hidden"
            ];
        }

        connect() {
        }

        delete(e) {
            e.preventDefault()
            if (window.confirm("Êtes-vous sûr ?")) {
                this.element.style.display = "none";
                this.destroy_hiddenTarget.value = "1";
            }
        }

        expand_collapse(e) {
            e.preventDefault();
            if ($(e.currentTarget).closest('.split_description')[0].classList.toggle("collapsed")) {
                e.currentTarget.text = e.currentTarget.getAttribute("data-label-expand")
            } else {
                e.currentTarget.text = e.currentTarget.getAttribute("data-label-collapse")
                applySelect2ToSelects()
                makeListsSortable()
            }
        }
    });
})();
