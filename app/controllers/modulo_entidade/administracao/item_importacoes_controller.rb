#encoding: UTF-8

class ModuloEntidade::Administracao::ItemImportacoesController < ModuloEntidade::AdminitracaoController

	before_filter :load_importacao

	def new
		@item_importacao = ItemImportacao.new
	end

	def create
		@item_importacao = ItemImportacao.new(params[:item_importacao])
		@item_importacao.importacao = @importacao
		respond_to do |format|
      		format.js
    	end
	end

	def update
		@item_importacao = ItemImportacao.find(params[:id])
		@item_importacao.importacao = @importacao
		respond_to do |format|
      		format.js
    	end
	end

	def edit
		@item_importacao = ItemImportacao.find params[:id]
	end

	def destroy
		@item_importacao = @importacao.item_importacoes.find params[:id]
		@item_importacao.destroy
		redirect_to [:entidade, :administracao, @importacao], notice: {success: 'Item excluído com sucesso!'}
	end

	def execute
		@item_importacao = @importacao.item_importacoes.find params[:id]
		@item_importacao_job = ItemImportacaoJob.new :unidade_id => @importacao.unidade_id,:item_importacao_id=>@item_importacao.id
		@item_importacao_job.save!
		@item_importacao_job.delay.run_function
		respond_to do |format|
      		format.js
    	end
	end
	
	private

	def load_importacao
		@importacao = Importacao.find params[:importacao_id]
	end

	def load_title_end_subtitle
	    @title = case params[:action]
	      when "index" then "Itens Importação"
	      when "new" then "Novo Item de Importação"
	      when "create" then "Novo Item de Importação"
	      when "edit" then "Editar Item de Importação"
	      when "update" then "Atualizar Item de Importação"
	      when "show" then "Detalhes de Item de Importação"
	      else "SubTitle"
	    end
  end
end
