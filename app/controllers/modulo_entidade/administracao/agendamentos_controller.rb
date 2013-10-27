# encoding: UTF-8
class ModuloEntidade::Administracao::AgendamentosController < ModuloEntidade::AdminitracaoController
  


  def index
    @agendamentos = current_entidade.agendamentos
  end

  def show
    @agendamento = Agendamento.find params[:id]
  end

  def new
    @agendamento = Agendamento.new
  end

  def create
    @agendamento = Agendamento.new(params[:agendamento])
      @agendamento.entidade = current_entidade
      if @agendamento.save
          redirect_to [:entidade, :administracao, @agendamento], notice: {success: 'Agendamento criado com sucesso.'}
      else
          render action: 'new'
      end
  end

  def edit
    @agendamento = Agendamento.find params[:id]
  end

  def update
    @agendamento = Agendamento.find params[:id]
    if @Agendamento.update_attributes(params[:agendamento])
      redirect_to [:entidade, :administracao, @agendamento], notice: {success: 'Agendamento atualizado com sucesso.'}
    else
      render action:'edit'
    end
  end

  def destroy
      @agendamento = Agendamento.find(params[:id])
      @Agendamento.destroy
      redirect_to [:entidade, :administracao, :agendamentos], notice: {success: 'Agendamento excluído com sucesso.'}
    end


private

  def load_title_end_subtitle
    @title = case params[:action]
      when "index" then "Agendamentos"
      when "new" then "Novo Agendamento"
      when "create" then "Novo Agendamento"
      when "edit" then "Editar Agendamento"
      when "update" then "Atualizar Agendamento"
      when "show" then "Detalhes Agendamento"
      else "SubTitle"
    end
  end

end
