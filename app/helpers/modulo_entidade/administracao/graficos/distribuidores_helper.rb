#encoding: UTF-8

module ModuloEntidade::Administracao::Graficos::DistribuidoresHelper

  BR_MONTHNAMES = %w(Janeiro Fevereiro Março Abril Maio Junho Julho Agosto Setembro Outubro Novembro Dezembro)
  BR_ABBR_MONTHNAMES = %w(Jan Fev Mar Abr Mai Jun Jul Ago Set Out Nov Dez)
  ANOS = %w(2013 2012 2011 2010 2009 2008)

  def meses_to_graficos_for_select
  	select = []
  	BR_MONTHNAMES.each_with_index do |mes, index|
  		select << [mes, (index + 1)]
  	end
  	select
  end

  def anos_to_graficos_for_select
  	select = []
  	ANOS.each{|ano| select << [ano] }
  end

end
