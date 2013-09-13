class ModuloEntidade::AdminitracaoController < EntidadeController

  before_filter :authenticate_usuario_is_admin!

  def index
  end

end
