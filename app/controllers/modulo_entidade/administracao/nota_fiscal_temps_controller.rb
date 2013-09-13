# encoding: UTF-8

class ModuloEntidade::Administracao::NotaFiscalTempsController < ModuloEntidade::AdminitracaoController

  def index
    params[:pesquisa] ||= {}
    @nota_fiscal_temps = NotaFiscalTemp.pesquisa(current_entidade, params[:pesquisa])
                                       .page(params[:page])
                                       .per(20)
  end

  def show
    @nota_fiscal_temp = NotaFiscalTemp.find(params[:id])
  end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Relatório da Importação de Notas Fiscais"
      when "show" then "Erros da Importação de Notas Fiscais"
      else "SubTitle"
    end
  end

end
