# encoding: UTF-8

class ModuloEntidade::Administracao::ProdutoTempsController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @produto_temps = ProdutoTemp.pesquisa(current_entidade, params[:pesquisa])
                                .page(params[:page])
                                .per(20)
  end

  def show
    @produto_temp = ProdutoTemp.find(params[:id])
  end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Relatório da Importação de Produtos"
      when "show" then "Erros da Importação de Produtos"
      else "SubTitle"
    end
  end

end
