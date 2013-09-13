$('#notice_over').remove();
<% if @resultado.blank? || @resultado.first.blank? %>
  html  = '<div id="notice_over">'
  html += '<div class="alert alert-error alert-section">'
  html += '<button class="close">×</button>'
  html += '<strong>Erro! </strong>'
  html += 'Não foi possível gerar o relatório. Verifique os filtros!'
  html += '</div>'
  html += '</div>'
  $('body').append(html);
  $('#resultado_relatorio').html('');
<% else %>
$('#resultado_relatorio').html('');
  <% @resultado.each do |resultado| %>
    $('#resultado_relatorio').append("<%= escape_javascript render(partial: 'resultado', object: resultado) %>");
  <% end %>
  duplo_clique_tabela();
<% end %>
$('#loading').modal('toggle');
