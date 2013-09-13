# encoding: UTF-8

class ModuloEntidade::Administracao::VendedoresController < ModuloEntidade::AdminitracaoController

	def index
    params[:pesquisa] ||={}
    @vendedores = Vendedor.pesquisa(current_entidade, params[:pesquisa]).page(params[:page]).per(20)
	end

	def show
		@vendedor = Vendedor.find(params[:id])
	end

private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Vendedores"
      when "new" then "Novo Vendedor"
      when "create" then "Novo Vendedor"
      when "edit" then "Editar Vendedor"
      when "update" then "Atualizar Vendedor"
      when "show" then "Detalhes Vendedor"
      else "SubTitle"
    end
  end


end

