# encoding: UTF-8

class ModuloEntidade::Administracao::Graficos::DistribuidoresController  < ModuloEntidade::AdminitracaoController

	skip_before_filter :authenticate_usuario_is_admin!

	def index
		params[:graficos] ||= { mes: Date.today.month, ano: Date.today.year }
		@ranking_clientes_quantidade = GraficoDistribuidor.ranking_clientes_quantidade(params[:graficos], current_user)
		@ranking_clientes_faturamento = GraficoDistribuidor.ranking_clientes_faturamento(params[:graficos], current_user)
		@ranking_produtos_quantidade = GraficoDistribuidor.ranking_produtos_quantidade(params[:graficos], current_user)
		@ranking_produtos_faturamento = GraficoDistribuidor.ranking_produtos_faturamento(params[:graficos], current_user)
		@vendas_por_distribuidor = GraficoDistribuidor.vendas_por_distribuidor(params[:graficos], current_user)
	end


  private

    def load_title_end_subtitle
      @title = 'Dashboard'
      # @subtitle = case params[:action]
      #   when 'ranking_produtos_index' then 'Ranking de Produtos (Quantidade e Faturamento)'
      #   else 'Subtitle'
      # end
    end

end
