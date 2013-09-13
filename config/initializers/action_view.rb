TrippingOcto::Application.config.action_view.field_error_proc = Proc.new { |html_tag, instance| html_tag.html_safe }
