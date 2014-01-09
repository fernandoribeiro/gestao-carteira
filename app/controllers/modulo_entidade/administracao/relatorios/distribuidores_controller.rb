#encoding: UTF-8

class ModuloEntidade::Administracao::Relatorios::DistribuidoresController < ModuloEntidade::AdminitracaoController

skip_before_filter :authenticate_usuario_is_admin!

### RANKING DE PRODUTOS
	def ranking_produtos_index
		params[:relatorios] ||= {}
	end

  def ranking_produtos_run
    @resultado = RelatorioDistribuidor.ranking_produtos(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### RANKING DE PRODUTOS


### RANKING DE CLIENTES
  def ranking_clientes_index
    params[:relatorios] ||= {}
  end

  def ranking_clientes_run
    @resultado = RelatorioDistribuidor.ranking_clientes(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### RANKING DE CLIENTES


### VENDAS POR DISTRIBUIDOR
  def vendas_distribuidores_index
    params[:relatorios] ||= {}
  end

  def vendas_distribuidores_run
    @resultado = RelatorioDistribuidor.vendas_por_distribuidor(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### VENDAS POR DISTRIBUIDOR


### CURVA ABC DE RODUTOS
  def curva_abc_produtos_index
    params[:relatorios] ||= {}
  end

  def curva_abc_produtos_run
    @resultado = RelatorioDistribuidor.curva_abc_produtos(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### CURVA ABC DE RODUTOS


### ACOMPANHAMENTO MES A MES
  def acompanhamento_mes_a_mes_index
    params[:relatorios] ||= {}
  end

  def acompanhamento_mes_a_mes_run
    @resultado = RelatorioDistribuidor.acompanhamento_mes_a_mes(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### ACOMPANHAMENTO MES A MES


### VENDAS POR CATEGORIA
  def vendas_categorias_index
    params[:relatorios] ||= {}
  end

  def vendas_categorias_run
    @resultado = RelatorioDistribuidor.vendas_por_categoria(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### VENDAS POR CATEGORIA


### EVOLUÇÃO DE CLIENTES
  def evolucao_clientes_index
    params[:relatorios] ||= {}
  end

  def evolucao_clientes_run
    @resultado = RelatorioDistribuidor.evolucao_clientes(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end
### EVOLUÇÃO DE CLIENTES


  private

    def load_title_end_subtitle
      @title = 'Relatórios'
      @subtitle = case params[:action]
        when 'ranking_produtos_index' then 'Ranking de Produtos (Quantidade e Faturamento)'
        when 'ranking_clientes_index' then 'Ranking de Clientes (Quantidade e Faturamento)'
        when 'vendas_distribuidores_index' then 'Vendas por Distribuidor'
        when 'curva_abc_produtos_index' then 'Curva ABC de Produtos'
        when 'acompanhamento_mes_a_mes_index' then 'Acompanhamento mês a mês'
        when 'vendas_categorias_index' then 'Vendas por Categoria'
        when 'evolucao_clientes_index' then 'Evolução de Clientes'
        else 'Subtitle'
      end
    end

end
