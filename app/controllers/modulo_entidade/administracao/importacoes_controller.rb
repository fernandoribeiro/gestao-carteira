#encoding: UTF-8

class ModuloEntidade::Administracao::ImportacoesController < ModuloEntidade::AdminitracaoController

	def index
		@importacoes = current_entidade.importacoes
	end

	def show
		@importacao = Importacao.find params[:id]
		@itens_job = ItemImportacaoJob.joins(:item_importacao).where("item_importacoes.importacao_id = ?",@importacao)
	end

	def new
		@importacao = Importacao.new
	end

	def create
		@importacao = Importacao.new(params[:importacao])
    	@importacao.entidade = current_entidade
    	if @importacao.save
      		redirect_to [:entidade, :administracao, @importacao], notice: {success: 'Importação criada com sucesso.'}
    	else
      		render action: 'new'
    	end
	end

	def edit
		@importacao = Importacao.find params[:id]
	end

	def update
		@importacao = Importacao.find params[:id]
		if @importacao.update_attributes(params[:importacao])
			redirect_to [:entidade, :administracao, @importacao], notice: {success: 'Importação atualizada com sucesso.'}
		else
			render action:'edit'
		end
	end

	def load_header_of_spreadsheet
		@importacao = Importacao.find params[:id]
		respond_to do |format|
      		format.js
    	end
	end

	def destroy
	    @importacao = Importacao.find(params[:id])
	    @importacao.destroy
	    redirect_to [:entidade, :administracao, :importacoes], notice: {success: 'Importação excluída com sucesso.'}
  	end

  	def jobs
  		if current_user.eh_administrador
  			unidades = current_user.entidade.unidades.collect(&:id)
  		else
  			unidades = current_user.unidades.collect(&:id)
  		end
  		@jobs = ItemImportacaoJob.where("unidade_id in (?)",unidades).page(params[:page]).per(10)
  	end

private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Importações"
      when "new" then "Nova Importação"
      when "create" then "Nova Importação"
      when "edit" then "Editar Importação"
      when "update" then "Atualizar Importação"
      when "show" then "Detalhes Importação"
      when "jobs" then "Jobs de Importação"
      else "SubTitle"
    end
  end

end
