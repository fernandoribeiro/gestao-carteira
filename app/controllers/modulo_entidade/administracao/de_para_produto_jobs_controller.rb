#encoding: UTF-8

class ModuloEntidade::Administracao::DeParaProdutoJobsController < ModuloEntidade::AdminitracaoController

  def index
    @de_para_produto_jobs = DeParaProdutoJob.where(unidade_id: current_entidade.unidades.pluck(:id)).page(params[:page]).per(20)
  end

  def show
    @de_para_produto_job = DeParaProdutoJob.find(params[:id])
  end

  def new
    @de_para_produto_job = DeParaProdutoJob.new
  end

  def create
    @de_para_produto_job = DeParaProdutoJob.new(params[:de_para_produto_job])
    if @de_para_produto_job.save
      if Rails.env.production?
        @de_para_produto_job.delay.run_importacao
      else
        @de_para_produto_job.run_importacao
      end
      redirect_to [:entidade, :administracao, @de_para_produto_job], notice: { success: 'Importação criada com sucesso.' }
    else
      render action: 'new'
    end
  end

  def destroy
    @de_para_produto_job = DeParaProdutoJob.find(params[:id])
    @de_para_produto_job.destroy
    redirect_to [:entidade, :administracao, :de_para_produto_jobs], notice: { success: 'Importação excluída com sucesso!' }
  end

  def download_file
    @de_para_produto_job = DeParaProdutoJob.find(params[:id])
    send_file(Rails.root.join('log', 'java', 'de_para_produtos', "de_para_produtos_#{@de_para_produto_job.id}", "erros_#{@de_para_produto_job.id}.log"), type: 'text/plain', filename: "erros_#{@de_para_produto_job.id}.log")
  end


  private

    def load_title_end_subtitle
      @title = case params[:action]
        when 'index' then 'Importação de De-Para de Produtos'
        when 'new' then 'Nova Importação de De-Para de Produtos'
        when 'create' then 'Nova Importação de De-Para de Produtos'
        when 'show' then 'Detalhes da importação de De-Para de Produtos'
        else 'SubTitle'
      end
    end

end
