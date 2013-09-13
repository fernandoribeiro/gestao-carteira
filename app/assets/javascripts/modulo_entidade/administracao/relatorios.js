var modificado = false;

function executa_relatorio() {
  if (modificado) {
    $('#loading').modal('show');
    $('#form_relatorio').submit();
    return false;
  }
  return true;
}

function inicializar_selectable() {
  $('#selectable, .selectable').selectable({
    stop: function() {
      $('#relatorios_dias').val('');
      $('#filtro_dias').html('');
      var values = ''
      var filtro_text = '';
      var cont = 0;
      $('.ui-selected', this).each(function() {
        if (cont == 0) {
          filtro_text = '<ol class="titulo">Dias</ol>';
        }
        values += ($(this).attr('id') + '#');
        filtro_text += ('<li>' + $(this).attr('id') + '</li>' + ', ');
        cont += 1;
      });
      $('#relatorios_dias').val(values);
      $('#filtro_dias').append(filtro_text);
      modificado = true;
      executa_relatorio();
    }
  });
}

function inicializar_um_selectable() {
  $('.ui-one-state-default').on('click', function() {
    $(this).addClass('ui-selected').siblings().removeClass('ui-selected');
    $('#relatorios_meses').val($(this).attr('id'));
    var filtro_text = '<ol class="titulo">Mês/Ano</ol>';
    filtro_text += ('<li>' + $(this).text() + '<li/>');
    $('#filtro_mes_ano').html(filtro_text);
  });
}

function executa_dados_iniciais() {
  var current_date = new Date();
  $('#relatorios_indicador_id').change(function() {
    if ($(this).val()) {
      $('#relatorios_meses').val((current_date.getMonth() + 1) + '_' + current_date.getFullYear());
      $.ajax({
        type: 'POST',
        url: carregaMesesAnosUrl,
        dataType: 'script',
        data: {
          indicador_id: $(this).val()
        },
      });
    } else {
      $('.selectable-one').remove();
      $('#relatorios_meses').val('');
    }
  });
  $('#relatorios_indicador_id').change();

  modificado = true;
  executa_relatorio();
  // $('#relatorios_mes_ano_corrente').change();
}

function minimiza_maximiza_div_lista_filtros() {
  $('#titulo_filtros').click(function() {
    if ($(this).parent().data('status') == 'open') {
      $(this).parent().animate({
        height: '20px',
        opacity: 'show'
      }, 'slow');
      $(this).parent().data('status', 'close');
    } else {
      $(this).parent().animate({
        height: '300px'
      }, 'slow');
      $(this).parent().data('status', 'open');
    }
  });
}

function colocando_select_tag_nos_filtros() {
  $('select').change(function() {
    var filtro_text = '';
    if ($(this).val()) {
      filtro_text = '<ol class="titulo">' + $(this).data('titulo') + '</ol>';
      filtro_text += ('<li>' + $('option:selected', $(this)).text() + '<li/>');
    }
    $('#' + $(this).data('filtro')).html(filtro_text);
  })
}

function corrige_tamanho_div_conteudo_da_pagina() {
  $('#page_content').css({
    'width': '1240px',
    'padding-top': '35px'
  })
}

function corrige_tamanho_div_titulo() {
  $('.page-header').css({
    'margin': 0,
    'padding-bottom': 0,
    'border-bottom': 0
  });
  $('h1').css({
    'font-size': '25px'
  });
}

function verifica_mudancas_no_form() {
  $('input').blur(function() {
    modificado = true;
    executa_relatorio();
  });
  $('select.run').change(function() {
    modificado = true;
    executa_relatorio();
  });
  // $('.selectable-one').on('click', function() {
  //   modificado = true;
  //   executa_relatorio();
  // });
}

function carrega_dias_uteis() {
  $('#relatorios_meta_id').change(function() {
    if ($(this).val()) {
      $.ajax({
        type: 'POST',
        url: carregaDiasUteisUrl,
        dataType: 'script',
        data: {
          meta_id: $(this).val()
        },
      });
    } else {
      $('#relatorios_dias_uteis').attr('disabled', 'disabled');
      $('#relatorios_dias_uteis').val(null);
    }
  });
}

function duplo_clique_tabela() {
  $('.acessar_dados').on('dblclick', function() {
    $.ajax({
      type: 'POST',
      url: carregaDadosDosIndicadoresUrl,
      dataType: 'script',
      data: {
        relatorios: {
          indicador_id: $(this).parents('tr').data('indicador'),
          frequencia_id: $(this).parents('tr').data('frequencia'),
          valor_id: $(this).parents('tr').data('valor'),
          unidade_id: $('#relatorios_unidade_id').val(),
          meta_id: $('#relatorios_meta_id').val(),
          dias_uteis: $('#relatorios_dias_uteis').val(),
          meses: $('#relatorios_meses').val(),
          total: $(this).parents('tr').data('total')
        }
      },
      beforeSend: function() {
        $('#loading').modal('show');
      },
      complete: function() {
        $('#loading').modal('toggle');
      },
      success: function() {
        $('#loading').modal('toggle');
      }
    });
  });
}
