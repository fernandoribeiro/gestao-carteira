# encoding: UTF-8

class ModuloEntidade::Administracao::ConjuntoIndicadoresController < ModuloEntidade::AdminitracaoController

  def index
    @conjunto_indicadores = current_entidade.conjunto_indicadores.order(:nome)
    if (params[:pesquisa].present?)
      @conjunto_indicadores = @conjunto_indicadores.where("nome like ?", "%#{params[:pesquisa]}%")
    end
    @conjunto_indicadores = @conjunto_indicadores.page(params[:page]).per(10)
  end

  def show
    @conjunto_indicador = current_entidade.conjunto_indicadores.find(params[:id])
  end

  def new
    @conjunto_indicador = current_entidade.conjunto_indicadores.new
    @conjunto_indicador.indicador_valores = [IndicadorValor.init_valor, IndicadorValor.init_frequencia]
    @valid = false;
  end

  def edit
    @conjunto_indicador = current_entidade.conjunto_indicadores.find(params[:id])
    @valid = true;
  end

  def create
    @conjunto_indicador = current_entidade.conjunto_indicadores.new(params[:conjunto_indicador])
    if @conjunto_indicador.save
      redirect_to [:entidade, :administracao, @conjunto_indicador], notice: { success: 'Conjunto de Indicadores criado com sucesso.' }
    else
      render action: 'new'
    end
  end

  def update
    @conjunto_indicador = current_entidade.conjunto_indicadores.find(params[:id])
    if @conjunto_indicador.update_attributes(params[:conjunto_indicador])
      redirect_to [:entidade, :administracao, @conjunto_indicador], notice: { success: 'Conjunto de Indicadores alterado com sucesso.' }
    else
      render action: 'edit'
    end
  end

  def destroy
    @conjunto_indicador = current_entidade.conjunto_indicadores.find(params[:id])
    @conjunto_indicador.toggle_active
    redirect_to entidade_administracao_conjunto_indicadores_path, notice: {success: 'Situação do Conjunto de Indicadores alterada com sucesso.'}
  end

  def validar_edit
    params[:conjunto_indicador][:unidade_ids] = params[:conjunto_indicador].has_key?(:unidade_ids) ? params[:conjunto_indicador][:unidade_ids] : []
    @conjunto_indicador = current_entidade.conjunto_indicadores.find(params[:id])
    @conjunto_indicador.edit_attributes(params[:conjunto_indicador])
    @valid = @conjunto_indicador.valid?
    render action: 'validar', layout: false
  end

  def validar_new
    @conjunto_indicador = current_entidade.conjunto_indicadores.new(params[:conjunto_indicador])
    @valid = @conjunto_indicador.valid?
    render action: 'validar', layout: false
  end


  private

  def load_title_end_subtitle
    @title = "Conjunto de Indicadores"
    @subtitle = case params[:action]
      when "index" then "Lista de Conjuntos"
      when "new" then "Criar Conjunto"
      when "create" then "Criar Conjunto"
      when "edit" then "Editar Conjunto"
      when "update" then "Editar Conjunto"
      when "show" then "Detalhes do Conjunto"
      else "SubTitle"
    end
  end

end
