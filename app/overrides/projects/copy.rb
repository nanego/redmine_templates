Deface::Override.new  :virtual_path  => "projects/copy",
                      :name          => "copy-projects-templates",
                      :insert_after  => ".block:contains('@source_project.wiki.nil?')",
                      :text          => <<EOS
<label class="block"><%= check_box_tag 'only[]', 'issue_templates', true, :id => nil %> <%= l(:label_issue_templates) %> (<%= @source_project.issue_templates.nil? ? 0 : @source_project.issue_templates.count %>)</label>
EOS
