# encoding: UTF-8

class ModuloEntidade::Administracao::ClienteTempsController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @cliente_temps = ClienteTemp.pesquisa(current_entidade, params[:pesquisa])
                                .page(params[:page])
                                .per(20)
  end

  def show
    @cliente_temp = ClienteTemp.find(params[:id])
  end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Relatório da Importação de Clientes"
      when "show" then "Erros da Importação de Clientes"
      else "SubTitle"
    end
  end

end
