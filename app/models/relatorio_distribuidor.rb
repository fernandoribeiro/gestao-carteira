#encoding: UTF-8

class RelatorioDistribuidor < ActiveRecord::Base

	### TIPO DE RANKING
	FATURAMENTO = 14353
	QUANTIDADE  = 32546

	### TIPO DE ORDENAÇÃO
	MAIORES	= 98909
	MENORES = 47743

	### TIPO DE AGRUPAMENTO
	CATEGORIA 	 = 34566
  DISTRIBUIDOR = 34223
  VENDA_GERAL	 = 25267


	def self.ranking_produtos(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:tipo_ranking].blank? ||
			 params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			faturamento_total = 0
			quantidade_total  = 0
			sql_porcentagem   = 'nota_fiscais.valor >= 0'

			if params[:tipo_ranking].to_i == FATURAMENTO
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.valor) DESC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.valor) ASC'
				end
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.quantidade) DESC, produtos.nome ASC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.quantidade) ASC, produtos.nome ASC'
				end
			end

			itens = NotaFiscal.select('produtos.codigo_sistema_legado')
												.select('produtos.nome')
												.select('SUM(nota_fiscais.valor) AS faturamento')
												.select('SUM(nota_fiscais.quantidade) AS quantidade')
												.joins(:produto)
												.where('nota_fiscais.valor >= 0')

			if params[:data_inicial].present?
				itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND data_emissao >= '#{params[:data_inicial].to_date}'"
			end

			if params[:data_final].present?
				itens = itens.where('data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND data_emissao <= '#{params[:data_final].to_date}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			itens = itens.select("to_char(ROUND(CAST(float8(
	   												(
	   													SUM(nota_fiscais.valor) /
	   													(SELECT SUM(nota_fiscais.valor)
	    												 FROM nota_fiscais
																	INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
	    												 WHERE #{sql_porcentagem}    															 			 
	   													)) * 100
														) AS numeric), 2), '990D99') AS perc_faturamento")
		itens = itens.select("to_char(ROUND(CAST(float8(
													(
	   												SUM(nota_fiscais.quantidade) /
	   												(SELECT SUM(nota_fiscais.quantidade)
	    											 FROM nota_fiscais
																INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
	    											 WHERE #{sql_porcentagem}
	    											)) * 100
													) AS numeric), 2), '990D99') AS perc_quantidade")

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
			faturamento_total = 0
			quantidade_total  = 0
			sql_porcentagem		= 'nota_fiscais.valor >= 0'

			if params[:tipo_ranking].to_i == FATURAMENTO
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.valor) DESC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.valor) ASC'
				end
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.quantidade) DESC, clientes.nome_razao_social ASC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.quantidade) ASC, clientes.nome_razao_social ASC'
				end
			end

			itens = NotaFiscal.select('clientes.codigo_sistema_legado')
												.select('clientes.nome_razao_social')
												.select('SUM(nota_fiscais.valor) AS faturamento')
												.select('SUM(nota_fiscais.quantidade) AS quantidade')
												.joins(:cliente)
												.where('nota_fiscais.valor >= 0')

			if params[:data_inicial].present?
				itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND data_emissao >= '#{params[:data_inicial].to_date}'"
			end

			if params[:data_final].present?
				itens = itens.where('data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND data_emissao <= '#{params[:data_final].to_date}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			itens = itens.select("to_char(ROUND(CAST(float8(
	   												(
	   													SUM(nota_fiscais.valor) /
	   													(SELECT SUM(nota_fiscais.valor)
	    												 FROM nota_fiscais
																	INNER JOIN clientes ON clientes.id = nota_fiscais.cliente_id
	    												 WHERE #{sql_porcentagem}
	   													)) * 100
														) AS numeric), 2), '990D99') AS perc_faturamento")
			itens = itens.select("to_char(ROUND(CAST(float8(
														(
	   													SUM(nota_fiscais.quantidade) /
	   													(SELECT SUM(nota_fiscais.quantidade)
	    												 FROM nota_fiscais
																	INNER JOIN clientes ON clientes.id = nota_fiscais.cliente_id
	    												 WHERE #{sql_porcentagem}
	    												)) * 100
														) AS numeric), 2), '990D99') AS perc_quantidade")

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
			total_vendas = 0
			sql_porcentagem = ''

			if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.valor) DESC'
			elsif params[:ordenacao].to_i == MENORES
				ordenacao = 'SUM(nota_fiscais.valor) ASC'
			end

			itens = NotaFiscal.select('unidades.nome')
												.select('SUM(nota_fiscais.valor) AS total_vendas')
												.joins(:unidade)
												.where('nota_fiscais.valor >= 0')

			if params[:data_inicial].present?
				itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date)
			end

			if params[:data_final].present?
				itens = itens.where('data_emissao <= ?', params[:data_final].to_date)
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
				sql_porcentagem += " AND produto_id IN(#{params[:produto_ids].reject(&:blank?).join(', ')})"
			end

			itens = itens.select("to_char(ROUND(CAST(float8(
														(
															SUM(nota_fiscais.valor) /
	 														(SELECT SUM(nota_fiscais.valor)
	 		 												 FROM nota_fiscais
	 		 												 WHERE	data_emissao >= '01/01/2013' AND
																			data_emissao <= '31/12/2013' #{sql_porcentagem}
	 														)
	 													) * 100) AS numeric), 2), '990D99') AS perc_vendas")

			itens = itens.group('unidades.id')
			itens = itens.order(ordenacao)

			itens.each{|item|	total_vendas += item[:total_vendas].to_f}

			[true, itens, total_vendas]
		end
	end

	def self.curva_abc_produtos(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:ordenacao].blank? ||
			 params[:agrupamento].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			total_vendas = 0
			if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.valor) DESC'
			elsif params[:ordenacao].to_i == MENORES
				ordenacao = 'SUM(nota_fiscais.valor) ASC'
			end

			itens = NotaFiscal.select('produtos.codigo_sistema_legado, produtos.nome AS nome_produto')
												.select('SUM(nota_fiscais.valor) AS total_vendas')
												.joins(:produto)
												.where('nota_fiscais.valor >= 0')
												.group('produtos.codigo_sistema_legado, produtos.nome')
												.order(ordenacao)

			if params[:agrupamento].to_i == DISTRIBUIDOR
				itens = itens.select('unidades.nome AS distribuidor')
										 .joins(:unidade)
										 .group('unidades.id')
			elsif params[:agrupamento].to_i == CATEGORIA
			end

			if params[:data_inicial].present?
				itens = itens.where('data_emissao >= ?', params[:data_inicial].to_date)
			end

			if params[:data_final].present?
				itens = itens.where('data_emissao <= ?', params[:data_final].to_date)
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
			end

			itens.each{|item| total_vendas += item[:total_vendas].to_f }

			[true, itens, total_vendas]
		end
	end

end
