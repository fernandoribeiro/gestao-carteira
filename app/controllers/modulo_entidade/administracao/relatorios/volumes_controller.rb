class ModuloEntidade::Administracao::Relatorios::VolumesController < ModuloEntidade::AdminitracaoController
  
  
private

    def load_title_end_subtitle
      @title = 'Carteira de Clientes'
      @subtitle = case params[:action]
        when 'index' then 'Carteira de Clientes'
        else 'SubTitle'
      end
    end
  
end
