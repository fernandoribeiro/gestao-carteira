# encoding: utf-8
module ModuloEntidade::Administracao::ConjuntoIndicadoresHelper

  def tipo_periodo_for_select
    [['Selecione um Tipo de Periodo', '']] + ConjuntoIndicador::TIPO_PERIODO_VERBOSE.map{|key, value| [value, key]}
  end

  def abrangencia_for_select
    [['Selecione uma Abrangência', '']] + ConjuntoIndicador::ABRANGENCIA_VERBOSE.map{|key, value| [value, key]}
  end

  def operador_frequencia
    [['Selecione um Operador', '']] + IndicadorValor::OPERADOR_FREQUENCIA.map{|key| [IndicadorValor::OPERADOR_VERBOSE[key],  key]}
  end

  def operador_valor
    [['Selecione um Operador', '']] + IndicadorValor::OPERADOR_VALOR.map{|key| [IndicadorValor::OPERADOR_VERBOSE[key],  key]}
  end

  def add_object_link name, f, object, partial, where, funciton = ''
    html = render(partial, f: f, object: object)
    link_to_function raw(name), %{
      var new_object_id = new Date().getTime() ;
      var html = jQuery("#{escape_javascript html.gsub(/\n/, '')}".replace(/INDEX_JS/g, new_object_id)).hide();
      html.appendTo(jQuery("#{where}")).slideDown();
      #{funciton}
    }, class: 'btn btn-success'
  end

  def conjunto_indicadores_for_select
    ConjuntoIndicador.where(entidade_id: current_entidade.id, active: true)
                     .order(:nome)
                     .uniq
                     .map{ |conj| [conj.nome, conj.id] }
  end

end
