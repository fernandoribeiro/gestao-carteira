# encoding: UTF-8

class ModuloEntidade::Administracao::ProdutosController < ModuloEntidade::AdminitracaoController

	def index
    params[:pesquisa] ||= {}
		@produtos = Produto.pesquisa(current_entidade, params[:pesquisa]).page(params[:page]).per(20)
	end

	def show
		@produto = Produto.find params[:id]
	end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when 'index' then 'Produtos'
      when 'new' then 'Novo Produto'
      when 'create' then 'Novo Produto'
      when 'edit' then 'Editar Produto'
      when 'update' then 'Atualizar Produto'
      when 'show' then 'Detalhes Produto'
      else 'SubTitle'
    end
  end


end
