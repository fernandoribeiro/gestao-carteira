module ApplicationHelper

  def error_class_for(resource, key)
    resource.respond_to?(:errors) && resource.errors.has_key?(key) ? "error" : nil
  end

  def error_info_for(resource, key)
    resource.respond_to?(:errors) && resource.errors.has_key?(key) ? "<span class=\"help-inline\">#{resource.errors[key].first}</span>".html_safe : nil
  end

  def block_errors_for(resource, key)
    if resource.respond_to?(:errors) && resource.errors.has_key?(key)
      render "block_errors", errors: resource.errors[key]
    else
      nil
    end
  end

  def show_if_present(label, campo)
    "<p><b>#{label}: </b>#{campo}</p>".html_safe if campo.present?
  end

  def loading_image_tag(id, classe = nil)
    image_tag('ajax-loader.gif', id: id, class: classe)
  end

  def tipo_rankings_for_select
    [
      ['Faturamento', RelatorioDistribuidor::FATURAMENTO],
      ['Quantidade', RelatorioDistribuidor::QUANTIDADE]
    ]
  end

  def tipo_ordenacao_for_select
    [
      ['Decrescente', RelatorioDistribuidor::MAIORES],
      ['Crescente', RelatorioDistribuidor::MENORES]
    ]
  end

  def tipo_agrupamento_for_select
    [
      ['Categoria', RelatorioDistribuidor::CATEGORIA],
      ['Distribuidor', RelatorioDistribuidor::DISTRIBUIDOR],
      ['Venda geral', RelatorioDistribuidor::VENDA_GERAL]
    ]
  end

  def tipo_visoes_for_select
    [
      ['Categoria', RelatorioDistribuidor::CATEGORIA],
      ['Cliente', RelatorioDistribuidor::CLIENTES],
      ['Distribuidor', RelatorioDistribuidor::UNIDADES],
      ['Produto', RelatorioDistribuidor::PRODUTOS]
    ]
  end

end
