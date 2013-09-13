$('.selectable-one').remove();
$('#meses_e_anos').prepend('<%= escape_javascript(select_mes_e_ano_tag(@indicador.numero_minimo_periodos)) %>');
inicializar_um_selectable();
$('#<%= Date.today.month %>_<%= Date.today.year %>').click();
$('.selectable-one').on('click', function() {
  modificado = true;
  executa_relatorio();
});
