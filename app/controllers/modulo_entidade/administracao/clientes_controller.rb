# encoding: UTF-8

class ModuloEntidade::Administracao::ClientesController < ModuloEntidade::AdminitracaoController

	def index
    params[:pesquisa] ||= {}
		@clientes = Cliente.pesquisa(current_entidade, params[:pesquisa]).page(params[:page]).per(20)
	end

	def show
		@cliente = Cliente.find(params[:id])
	end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Clientes"
      when "new" then "Novo Cliente"
      when "create" then "Novo Cliente"
      when "edit" then "Editar Cliente"
      when "update" then "Atualizar Cliente"
      when "show" then "Detalhes Cliente"
      else "SubTitle"
    end
  end


end

