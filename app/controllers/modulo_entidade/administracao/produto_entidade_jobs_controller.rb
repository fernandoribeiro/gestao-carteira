#encoding: UTF-8

class ModuloEntidade::Administracao::ProdutoEntidadeJobsController < ModuloEntidade::AdminitracaoController

  def index
    @produto_entidade_jobs = ProdutoEntidadeJob.where(entidade_id: current_entidade.id).page(params[:page]).per(20)
  end

  def show
    @produto_entidade_job = ProdutoEntidadeJob.find(params[:id])
  end

  def new
    @produto_entidade_job = ProdutoEntidadeJob.new
  end

  def create
    @produto_entidade_job = ProdutoEntidadeJob.new(params[:produto_entidade_job])
    @produto_entidade_job.entidade_id = current_entidade.id
    if @produto_entidade_job.save
      if Rails.env.production?
        @produto_entidade_job.delay.run_importacao
      else
        @produto_entidade_job.run_importacao
      end
      redirect_to [:entidade, :administracao, @produto_entidade_job], notice: { success: 'Importação criada com sucesso.' }
    else
      render action: 'new'
    end
  end

  def destroy
    @produto_entidade_job = ProdutoEntidadeJob.find(params[:id])
    @produto_entidade_job.destroy
    redirect_to [:entidade, :administracao, :produto_entidade_jobs], notice: { success: 'Importação excluída com sucesso!' }
  end

  def download_file
    @produto_entidade_job = ProdutoEntidadeJob.find(params[:id])
    send_file(Rails.root.join('log', 'java', 'produtos_base', "produtos_base_#{@produto_entidade_job.id}", "erros_#{@produto_entidade_job.id}.log"), type: 'text/plain', filename: "erros_#{@produto_entidade_job.id}.log")
  end


  private

    def load_title_end_subtitle
      @title = case params[:action]
        when 'index' then 'Importação de Produtos Base'
        when 'new' then 'Nova Importação de Produtos Base'
        when 'create' then 'Nova Importação de Produtos Base'
        when 'show' then 'Detalhes da importação'
        else 'SubTitle'
      end
    end

end
