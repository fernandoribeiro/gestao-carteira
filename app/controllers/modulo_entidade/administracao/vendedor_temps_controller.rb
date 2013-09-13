# encoding: UTF-8

class ModuloEntidade::Administracao::VendedorTempsController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @vendedor_temps = VendedorTemp.pesquisa(current_entidade, params[:pesquisa])
                                  .page(params[:page])
                                  .per(20)
  end

  def show
    @vendedor_temp = VendedorTemp.find(params[:id])
  end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Relatório da Importação de Vendedores"
      when "show" then "Erros da Importação de Vendedores"
      else "SubTitle"
    end
  end

end
