#encoding: UTF-8

class ModuloEntidade::Administracao::Relatorios::CarteirasController < ModuloEntidade::AdminitracaoController

    skip_before_filter :authenticate_usuario_is_admin!

  def index
    params[:relatorios] ||= {}
  end

  def run_carteira
    # params[:relatorios][:unidade_id] =  unless current_user_is_admin?
    @resultado = RelatorioFaturamento.gera_relatorio_faturamento(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end

  def carrega_dias_uteis
    respond_to do |format|
      @meta = Meta.find(params[:meta_id])
      js  = "$('#relatorios_dias_uteis').val(#{@meta.dias_uteis});"
      js += "$('#relatorios_dias_uteis').removeAttr('disabled');"
      js += "executa_relatorio();"
      format.js { render js: js }
    end
  end

  def carrega_anos_meses
    @indicador = ConjuntoIndicador.find(params[:indicador_id])
    respond_to do |format|
      format.js
    end
  end

  def carrega_dados_indicadores
    @resultado = RelatorioFaturamento.clientes_em_uma_faixa(params[:relatorios])
    respond_to do |format|
      format.js
    end
  end


  private

    def load_title_end_subtitle
      @title = 'Carteira de Clientes'
      @subtitle = case params[:action]
        when 'index' then 'Carteira de Clientes'
        else 'SubTitle'
      end
    end

end
