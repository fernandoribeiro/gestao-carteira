#encoding: UTF-8

module ModuloEntidade::Administracao::RelatoriosHelper

  def select_dias_tag
    retorno = '<ol class="selectable">'
    31.times do |dia|
      dia = (dia + 1).to_s
      retorno += "<li class='ui-state-default' id='#{dia}'>"
      retorno += dia
      retorno += '</li>'
    end
    retorno += '</ol>'
    retorno.html_safe
  end

  def select_mes_e_ano_tag(numero_de_periodos)
    ano_inicial = (Date.today - numero_de_periodos.to_i.month).year rescue 2000
    mes_inicial = (Date.today - numero_de_periodos.to_i.month).month rescue 1
    ano_atual = Date.today.year
    mes_atual = Date.today.month
    retorno = '<ol class="selectable-one">'
    (ano_inicial..ano_atual).each do |ano|
      if ano == ano_atual
        (1..mes_atual).each do |mes|
          id = "#{mes}_#{ano}"
          conteudo = "#{Date::ABBR_MONTHNAMES[mes]}/#{ano}"
          retorno += "<li class='ui-one-state-default' id='#{id}'>"
          retorno += conteudo.downcase
          retorno += '</li>'
        end
      elsif ano == ano_inicial
        (mes_inicial..12).each do |mes|
          id = "#{mes}_#{ano}"
          conteudo = "#{Date::ABBR_MONTHNAMES[mes]}/#{ano}"
          retorno += "<li class='ui-one-state-default' id='#{id}'>"
          retorno += conteudo.downcase
          retorno += '</li>'
        end
      else
        (1..12).each do |mes|
          id = "#{mes}_#{ano}"
          conteudo = "#{Date::ABBR_MONTHNAMES[mes]}/#{ano}"
          retorno += "<li class='ui-one-state-default' id='#{id}'>"
          retorno += conteudo.downcase
          retorno += '</li>'
        end
      end
    end
    retorno += '</ol>'
    retorno.html_safe
  end

  def select_mes_e_ano_corrente_tag
    ano_inicial = 2000
    ano_atual = Date.today.year
    mes_atual = Date.today.month
    retorno = []
    (ano_inicial..ano_atual).each do |ano|
      if ano == ano_atual
        (1..mes_atual).each do |mes|
          id = "#{mes}_#{ano}"
          conteudo = "#{Date::ABBR_MONTHNAMES[mes]}/#{ano}"
          retorno << [conteudo.downcase, id]
        end
      else
        (1..12).each do |mes|
          id = "#{mes}_#{ano}"
          conteudo = "#{Date::ABBR_MONTHNAMES[mes]}/#{ano}"
          retorno << [conteudo.downcase, id]
        end
      end
    end
    select_tag('relatorios[mes_ano_corrente]',
                options_for_select(retorno.reverse),
                # options_for_select(retorno.reverse, selected: "#{mes_atual}_#{ano_atual}"),
                prompt: 'MÊS CORRENTE',
                :'data-filtro' => 'filtro_mes_corrente', :'data-titulo' => 'Mês Corrente',
                class: 'medium-select run'
              )
  end

end
