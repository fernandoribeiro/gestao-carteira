#encoding: UTF-8

class ModuloEntidade::Administracao::Relatorios::LogAcessosController < ModuloEntidade::AdminitracaoController

  skip_before_filter :authenticate_usuario_is_admin!
  
	def index
    params[:pesquisa] ||= {}
    @log_acessos = LogAcesso.pesquisa(current_entidade.id, params[:pesquisa]).page(params[:page]).per(20)
	end


  private

    def load_title_end_subtitle
      @title = 'Relatórios'
      @subtitle = case params[:action]
        when 'index' then 'Histórico de Acessos'
        else 'Subtitle'
      end
    end

end
