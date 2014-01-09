module ModuloEntidade::Administracao::UnidadesHelper

  def unidades_for_select
   begin
	  	unless current_user.eh_administrador?
	  		current_user.unidades.order(:nome).uniq.map{|u| [u.nome, u.id]}
	    else
	    	Unidade.where(entidade_id: current_entidade.id, active: true).order(:nome).uniq.map{ |unid| [unid.nome, unid.id] }
	  	end
	  rescue Exception=>e
	  	[]
	  end
  end

end
