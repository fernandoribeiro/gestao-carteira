module ModuloEntidade::SessionHelper

  def unidades_for_select_session
    options = [['Todas', 'all']]
    options += current_user.unidades.map{|u| [u.nome, u.id]}
    opcao_escolhida = 'all'
    if cookies[:unidades_ids].present?
      unless cookies[:unidades_ids].include?('&')
        opcao_escolhida = cookies[:unidades_ids].to_i
      end
    end
    options_for_select(options, selected: opcao_escolhida)
  end

end
