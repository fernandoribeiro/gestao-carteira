# encoding: UTF-8

class ModuloEntidade::Administracao::Relatorios::DistribuidoresController < ModuloEntidade::AdminitracaoController

	def ranking_produtos_index
		params[:relatorios] ||= {}
	end

  def ranking_produtos_run
    @resultado = RelatorioDistribuidor.ranking_produtos(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end


  private

    def load_title_end_subtitle
      @title = 'Relatórios'
      @subtitle = case params[:action]
        when 'ranking_produtos_index' then 'Ranking de Produtos (Quantidade e Faturamento)'
        else 'Subtitle'
      end
    end

end
