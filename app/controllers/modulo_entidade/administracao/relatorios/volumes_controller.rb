class ModuloEntidade::Administracao::Relatorios::VolumesController < ModuloEntidade::AdminitracaoController
  
  skip_before_filter :authenticate_usuario_is_admin!
  
private

    def load_title_end_subtitle
      @title = 'Carteira de Clientes'
      @subtitle = case params[:action]
        when 'index' then 'Carteira de Clientes'
        else 'SubTitle'
      end
    end
  
end
