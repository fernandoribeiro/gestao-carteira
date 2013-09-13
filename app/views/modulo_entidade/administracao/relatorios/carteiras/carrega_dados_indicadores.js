<% if @resultado.blank? || @resultado.first.blank? %>
  $('#modal_resultados').html('');
<% else %>
  $('#modal_resultados').html("<%= escape_javascript render(partial: 'resultado_modal', locals: { object: @resultado }) %>");
<% end %>
$('#loading').modal('toggle');
$('#modal_detalhes').modal();
