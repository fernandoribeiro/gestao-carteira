class ModuloEntidade::DashboardsController < EntidadeController

  def index
    p cookies[:unidades_ids]
  end

  private

    def load_title_end_subtitle
      @title = 'Dashboard'
    end

end
