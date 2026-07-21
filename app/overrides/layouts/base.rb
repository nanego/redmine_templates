    Deface::Override.new :virtual_path => 'layouts/base',
                     :name => 'add-js-script-to-layout',
                     :insert_bottom => 'body' do
  <<-SCRIPT
    <% if @project.present? %>
      <script type="text/javascript">
        if ($('#main-menu .menu-children li a.new-issue-sub').length > 0)
        {
          $('#main-menu').on('click', 'a.new-issue', function() {
            return false;
          });
          $('#main-menu a.new-issue').css("cursor", "default");
        }
      </script>
    <% end %>
  SCRIPT
end
