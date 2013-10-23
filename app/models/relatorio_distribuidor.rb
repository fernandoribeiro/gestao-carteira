#encoding: UTF-8

class RelatorioDistribuidor < ActiveRecord::Base

	### TIPO DE RANKING
	FATURAMENTO = 14353
	QUANTIDADE  = 32546

	### TIPO DE ORDENAÇÃO
	MAIORES	= 98909
	MENORES = 47743


	def self.ranking_produtos(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:tipo_ranking].blank? ||
			 params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			if params[:tipo_ranking].to_i == FATURAMENTO
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) DESC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) ASC' if params[:ordenacao].to_i == MENORES
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				ordenacao = 'COUNT(produtos.codigo_sistema_legado) DESC, produtos.nome ASC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'COUNT(produtos.codigo_sistema_legado) ASC, produtos.nome ASC' if params[:ordenacao].to_i == MENORES
			end

			faturamento_total = 0
			quantidade_total  = 0
			itens = NotaFiscal.select('produtos.codigo_sistema_legado')
												.select('produtos.nome')
												.select('SUM((nota_fiscais.quantidade * nota_fiscais.valor)) AS faturamento')
												.select('COUNT(produtos.codigo_sistema_legado) AS quantidade')
												.joins(:produto)
			itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date) if params[:data_inicial].present?
			itens = itens.where('data_emissao <= ?', params[:data_final].to_date) if params[:data_final].present?
			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
			end
			itens = itens.group('produtos.codigo_sistema_legado, produtos.nome')
			itens = itens.order(ordenacao)

			itens.each do |item|
				faturamento_total += item[:faturamento].to_f
				quantidade_total += item[:quantidade].to_f
			end
			[true, itens, faturamento_total, quantidade_total]
		end
	end


	def self.ranking_clientes(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:tipo_ranking].blank? ||
			 params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			if params[:tipo_ranking].to_i == FATURAMENTO
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) DESC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) ASC' if params[:ordenacao].to_i == MENORES
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				ordenacao = 'COUNT(clientes.codigo_sistema_legado) DESC, clientes.nome_razao_social ASC' if params[:ordenacao].to_i == MAIORES
				ordenacao = 'COUNT(clientes.codigo_sistema_legado) ASC, clientes.nome_razao_social ASC' if params[:ordenacao].to_i == MENORES
			end

			faturamento_total = 0
			quantidade_total  = 0
			itens = NotaFiscal.select('clientes.codigo_sistema_legado')
												.select('clientes.nome_razao_social')
												.select('SUM((nota_fiscais.quantidade * nota_fiscais.valor)) AS faturamento')
												.select('COUNT(clientes.codigo_sistema_legado) AS quantidade')
												.joins(:cliente)
			itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date) if params[:data_inicial].present?
			itens = itens.where('data_emissao <= ?', params[:data_final].to_date) if params[:data_final].present?
			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
			end
			itens = itens.group('clientes.codigo_sistema_legado, clientes.nome_razao_social')
			itens = itens.order(ordenacao)

			itens.each do |item|
				faturamento_total += item[:faturamento].to_f
				quantidade_total += item[:quantidade].to_f
			end
			[true, itens, faturamento_total, quantidade_total]
		end
	end


	def self.vendas_por_distribuidor(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) DESC' if params[:ordenacao].to_i == MAIORES
			ordenacao = 'SUM(nota_fiscais.quantidade * nota_fiscais.valor) ASC' if params[:ordenacao].to_i == MENORES

			vendas_total = 0
			itens = NotaFiscal.select('unidades.nome')
												.select('SUM((nota_fiscais.quantidade * nota_fiscais.valor)) AS total_vendas')
												.joins(:unidade)
			itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date) if params[:data_inicial].present?
			itens = itens.where('data_emissao <= ?', params[:data_final].to_date) if params[:data_final].present?
			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
			end
			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
			end
			itens = itens.group('unidades.id')
			itens = itens.order(ordenacao)

			itens.each do |item|
				vendas_total += item[:total_vendas].to_f
			end
			[true, itens, vendas_total]
		end
	end

end
