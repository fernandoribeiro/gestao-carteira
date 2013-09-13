$CONJUNTO_INDICADORES_CONTROLLER = {
  form: function(){
    $(function(){
      $('#tbody_valor, #tbody_frequencia').on('click','.remover_linha', function(){
        var tr = $(this).parents('tr');
        var field = tr.find('.field_destroy');
        field.val('1');
        $('#div_destroy_fields').append(field.clone());
        tr.remove();
        return false;
      });

      var change_operador_frequencia = function(operador){
        var tr = operador.parents('tr');
        if(operador.val() != '5'){
          tr.find('.span_e_frequencia').hide();
          tr.find('.div_frequencia_maxima').hide();
          tr.find('.div_frequencia_maxima').find('input').val('');
        } else {
          tr.find('.span_e_frequencia').show();
          tr.find('.div_frequencia_maxima').show();
        }

        if(operador.val() == 3){
          tr.find('.div_frequencia_mimima').hide()
          tr.find('.div_frequencia_mimima').find('input').val('');
        } else {
          tr.find('.div_frequencia_mimima').show()
        }
      }

      $('#tbody_frequencia').on('change','.operador_frequencia', function(){
        change_operador_frequencia($(this));
      });

      $('.operador_frequencia').each(function(){
        change_operador_frequencia($(this));
      });


      var change_operador_valor = function(operador){
        var tr = operador.parents('tr');
        if(operador.val() != '5'){
          tr.find('.span_e_valor').hide();
          tr.find('.div_valor_maximo').hide();
          tr.find('.div_valor_maximo').find('input').val('');
        } else {
          tr.find('.span_e_valor').show();
          tr.find('.div_valor_maximo').show();
        }
      }

      $('#tbody_valor').on('change','.operador_valor', function(){
        change_operador_valor($(this));
      });

      $('.operador_valor').each(function(){
        change_operador_valor($(this));
      });


      var change_check_box_entidade = function(check_box){
        if(check_box.is(":checked")){
          $("#div_controls_entidade").show();
        } else {
          $("#div_controls_entidade").hide();
          $("#div_controls_entidade input").removeAttr('checked');
        }
      }

      change_check_box_entidade($("#conjunto_indicador_abrangencia_entidade").change(function(){
        change_check_box_entidade($(this));
      }));

      var change_check_box_unidades = function(check_box){
        if(check_box.is(":checked")){
          $("#div_controls_unidades").show();
        } else {
          $("#div_controls_unidades").hide();
          $("#div_controls_unidades input").removeAttr('checked');
        }
      }

      change_check_box_unidades($("#conjunto_indicador_abrangencia_unidade").change(function(){
        change_check_box_unidades($(this));
      }));

      $("#link_validar").click(function(){
        $.ajax({
          url: $(this).attr('href'),
          type: "post",
          dataType: "html",
          data: $("#form_conjunto_indicadores").serialize(),
          success: function(html){
            $('#div_form').html(html);
          }
        });
        return false;
      });

      $("#form_conjunto_indicadores").on("change", "input, select, text_area", function(){
        $('#button_save').attr('disabled', 'disabled');
      });

      $('#conjunto_indicador_numero_minimo_periodos').maskMoney({showSymbol:false, decimal:"", thousands:""});
      $('#tbody_frequencia .mask_frequencia').maskMoney({showSymbol:false, decimal:"", thousands:""});
      $('#tbody_valor .mask_valor').maskMoney({showSymbol:false, decimal:".", thousands:""});
      $('#tbody_valor .mask_valor').each(function(){
        $(this).val(parseFloat($(this).val()).toFixed(2));
      });
    });
  },

  add_mask_valor: function(){
    $('#tbody_valor tr:last .mask_valor').maskMoney({showSymbol:true, symbol:"", decimal:".", thousands:""});
  },
  add_mask_frequencia: function(){
    $('#tbody_frequencia tr:last .mask_frequencia').maskMoney({showSymbol:false, decimal:"", thousands:""});
  }
}
