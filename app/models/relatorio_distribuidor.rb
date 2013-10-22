#encoding: UTF-8

class RelatorioDistribuidor < ActiveRecord::Base

	### TIPO DE RANKING
	FATURAMENTO = 14353
	QUANTIDADE  = 32546

	### TIPO DE ORDENAÇÃO
	MAIORES	= 98909
	MENORES = 47743


	def self.ranking_produtos(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:unidade_ids].blank? ||
			 params[:tipo_ranking].blank? || params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			if params[:tipo_ranking].to_i == FATURAMENTO
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) DESC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) ASC' if params[:ordenacao].to_i == MENORES
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				ordenacao = 'COUNT(produtos.codigo_sistema_legado) DESC, produtos.codigo_sistema_legado DESC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'COUNT(produtos.codigo_sistema_legado) ASC, produtos.codigo_sistema_legado DESC' if params[:ordenacao].to_i == MENORES
			end

			faturamento_total = 0
			quantidade_total  = 0
			itens = NotaFiscal.select('produtos.codigo_sistema_legado')
												.select('produtos.nome')
												.select('SUM((nota_fiscais.quantidade * nota_fiscais.valor)) AS faturamento')
												.select('COUNT(produtos.codigo_sistema_legado) AS quantidade')
												.joins(:produto)
												.where('data_emissao >= ?', params[:data_inicial].to_date)
												.where('data_emissao <= ?', params[:data_final].to_date)
												.where(unidade_id: params[:unidade_ids])
												.group('produtos.codigo_sistema_legado, produtos.nome')
												.order(ordenacao)
			itens.each do |item|
				faturamento_total += item[:faturamento].to_f
				quantidade_total += item[:quantidade].to_f
			end
			[true, itens, faturamento_total, quantidade_total]
		end
	end

end
