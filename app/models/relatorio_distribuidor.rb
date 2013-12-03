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

	### TIPO DE VISÕES
	CLIENTES = 34232
	PRODUTOS = 10998
	UNIDADES = 78554


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
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao >= '#{params[:data_inicial].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao <= '#{params[:data_final].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
				itens = itens.where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
				sql_porcentagem += " AND produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})"

				itens = itens.select("to_char(ROUND(CAST(float8(
		   												(
		   													SUM(nota_fiscais.valor) /
		   													(SELECT SUM(nota_fiscais.valor)
		    												 FROM nota_fiscais
																		INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
																		INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
																		INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
		    												 WHERE #{sql_porcentagem}    															 			 
		   													)) * 100
															) AS numeric), 2), '990D99') AS perc_faturamento")
				itens = itens.select("to_char(ROUND(CAST(float8(
														 (
		   												SUM(nota_fiscais.quantidade) /
		   												(SELECT SUM(nota_fiscais.quantidade)
		    											 FROM nota_fiscais
																	INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
																	INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
																	INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
		    											 WHERE #{sql_porcentagem}
		    											)) * 100
														 ) AS numeric), 2), '990D99') AS perc_quantidade")
			else
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
			end

			itens = itens.group('produtos.codigo_sistema_legado, produtos.nome')
			itens = itens.order(ordenacao)

			itens.each do |item|
				faturamento_total += item[:faturamento].to_f
				quantidade_total += item[:quantidade].to_f
			end

			[true, itens, faturamento_total, quantidade_total, params[:ordenacao].to_i]
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
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao >= '#{params[:data_inicial].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao <= '#{params[:data_final].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.joins(:produto)
										 .joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
				itens = itens.where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
				sql_porcentagem += " AND produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})"

				itens = itens.select("to_char(ROUND(CAST(float8(
		   												(
		   													SUM(nota_fiscais.valor) /
		   													(SELECT SUM(nota_fiscais.valor)
		    												 FROM nota_fiscais
																		INNER JOIN clientes ON clientes.id = nota_fiscais.cliente_id
																		INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
										 								INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
										 								INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
		    												 WHERE #{sql_porcentagem}
		   													)) * 100
															) AS numeric), 2), '990D99') AS perc_faturamento")
				itens = itens.select("to_char(ROUND(CAST(float8(
															(
		   													SUM(nota_fiscais.quantidade) /
		   													(SELECT SUM(nota_fiscais.quantidade)
		    												 FROM nota_fiscais
																		INNER JOIN clientes ON clientes.id = nota_fiscais.cliente_id
																		INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
										 								INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
										 								INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
		    												 WHERE #{sql_porcentagem}
		    												)) * 100
															) AS numeric), 2), '990D99') AS perc_quantidade")
			else
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
			end

			itens = itens.group('clientes.codigo_sistema_legado, clientes.nome_razao_social')
			itens = itens.order(ordenacao)

			itens.each do |item|
				faturamento_total += item[:faturamento].to_f
				quantidade_total += item[:quantidade].to_f
			end

			[true, itens, faturamento_total, quantidade_total, params[:ordenacao].to_i]
		end
	end


	def self.vendas_por_distribuidor(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			total_vendas = 0
			sql_porcentagem = 'nota_fiscais.valor >= 0'

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
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao >= '#{params[:data_inicial].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao <= '#{params[:data_final].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.produto_id IN(#{params[:produto_ids].reject(&:blank?).join(', ')})"
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.joins(:produto)
										 .joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
				itens = itens.where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
				sql_porcentagem += " AND produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})"

				itens = itens.select("to_char(ROUND(CAST(float8(
															(
																SUM(nota_fiscais.valor) /
		 														(SELECT SUM(nota_fiscais.valor)
		 		 												 FROM nota_fiscais
																		INNER JOIN unidades ON unidades.id = nota_fiscais.unidade_id
																		INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
										 								INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
										 								INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
		 		 												 WHERE #{sql_porcentagem}
		 														)) * 100
															) AS numeric), 2), '990D99') AS perc_vendas")
			else
				itens = itens.select("to_char(ROUND(CAST(float8(
															(
																SUM(nota_fiscais.valor) /
		 														(SELECT SUM(nota_fiscais.valor)
		 		 												 FROM nota_fiscais
																		INNER JOIN unidades ON unidades.id = nota_fiscais.unidade_id
		 		 												 WHERE #{sql_porcentagem}
		 														)) * 100
															) AS numeric), 2), '990D99') AS perc_vendas")
			end
			itens = itens.group('unidades.id')
			itens = itens.order(ordenacao)

			itens.each{|item|	total_vendas += item[:total_vendas].to_f}

			[true, itens, total_vendas]
		end
	end


	def self.vendas_por_categoria(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			total_vendas = 0
			sql_porcentagem = 'nota_fiscais.valor >= 0'

			if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.valor) DESC'
			elsif params[:ordenacao].to_i == MENORES
				ordenacao = 'SUM(nota_fiscais.valor) ASC'
			end

			itens = NotaFiscal.select('produto_entidades.marca AS categoria')
												.select('SUM(nota_fiscais.valor) AS total_vendas')
												.joins(:produto)
										 		.joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 		.joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
												.where('nota_fiscais.valor >= 0')

			if params[:data_inicial].present?
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao >= '#{params[:data_inicial].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao <= '#{params[:data_final].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
				sql_porcentagem += " AND produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})"
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.produto_id IN(#{params[:produto_ids].reject(&:blank?).join(', ')})"
			end

			itens = itens.select("to_char(ROUND(CAST(float8(
														(
															SUM(nota_fiscais.valor) /
	 														(SELECT SUM(nota_fiscais.valor)
	 		 												 FROM nota_fiscais
		 		 												INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id
		 		 												INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id
											 					INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id
	 		 												 WHERE #{sql_porcentagem}
	 														)) * 100
														) AS numeric), 2), '990D99') AS perc_vendas")
			
			itens = itens.group('produto_entidades.marca')
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
			total_vendas 			= 0
			sql_porcentagem 	= 'nota_fiscais.valor >= 0'
			inner_porcentagem = ''

			if params[:ordenacao].to_i == MAIORES
				ordenacao = 'SUM(nota_fiscais.valor) DESC'
			elsif params[:ordenacao].to_i == MENORES
				ordenacao = 'SUM(nota_fiscais.valor) ASC'
			end

			itens = NotaFiscal.select('produtos.codigo_sistema_legado, produtos.nome AS nome_produto')
												.select('SUM(nota_fiscais.valor) AS total_vendas')
												.joins(:produto)
												.where('nota_fiscais.valor >= 0')

			if params[:agrupamento].to_i == DISTRIBUIDOR
				itens = itens.select('unidades.nome AS nome')
										 .joins(:unidade)
										 .group('unidades.id')
			elsif params[:agrupamento].to_i == CATEGORIA
				itens = itens.select('produto_entidades.marca AS nome')
										 .joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
										 .group('produto_entidades.marca')
				inner_porcentagem += 'INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id '
	 		 	inner_porcentagem += 'INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id '
				inner_porcentagem += 'INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id '
			end

			if params[:data_inicial].present?
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao >= '#{params[:data_inicial].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
				sql_porcentagem += " AND nota_fiscais.data_emissao <= '#{params[:data_final].to_date.strftime('%Y-%m-%d')}'"
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.unidade_id IN(#{params[:unidade_ids].reject(&:blank?).join(', ')})"
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
										 .where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
				inner_porcentagem += 'INNER JOIN produtos ON produtos.id = nota_fiscais.produto_id '
	 		 	inner_porcentagem += 'INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id '
				inner_porcentagem += 'INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id '
				sql_porcentagem += " AND produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})"
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
				sql_porcentagem += " AND nota_fiscais.produto_id IN(#{params[:produto_ids].reject(&:blank?).join(', ')})"
			end

			itens = itens.select("to_char(ROUND(CAST(float8(
														(
															SUM(nota_fiscais.valor) /
		 													(SELECT SUM(nota_fiscais.valor)
		 		 											 FROM nota_fiscais
		 		 											 #{inner_porcentagem}
		 		 											 WHERE #{sql_porcentagem}
		 													)) * 100
														) AS numeric), 2), '990D99') AS perc_vendas")

			itens = itens.group('produtos.codigo_sistema_legado, produtos.nome')
			itens = itens.order(ordenacao)

			itens.each{|item| total_vendas += item[:total_vendas].to_f }

			[true, itens, total_vendas, params[:ordenacao].to_i]
		end
	end


	def self.acompanhamento_mes_a_mes(params)
		if params[:data_inicial].blank? || params[:data_final].blank? || params[:tipo_ranking].blank? ||
			 params[:tipo_visao].blank? || params[:ordenacao].blank?
			[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
		else
			resultado ||= {}

			if params[:tipo_ranking].to_i == FATURAMENTO
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.valor) DESC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.valor) ASC'
				end
			elsif params[:tipo_ranking].to_i == QUANTIDADE
				if params[:ordenacao].to_i == MAIORES
					ordenacao = 'SUM(nota_fiscais.quantidade) DESC'
				elsif params[:ordenacao].to_i == MENORES
					ordenacao = 'SUM(nota_fiscais.quantidade) ASC'
				end
			end

			if params[:tipo_visao].to_i == CATEGORIA
				itens = NotaFiscal.select('produto_entidades.marca')
													.joins(:produto)
										 			.joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 			.joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
										 			.group('produto_entidades.marca')
			elsif params[:tipo_visao].to_i == CLIENTES
				itens = NotaFiscal.select('clientes.codigo_sistema_legado')
													.select('clientes.nome_razao_social')
													.joins(:cliente)
													.where('nota_fiscais.valor >= 0')
													.group('clientes.codigo_sistema_legado, clientes.nome_razao_social')
			elsif params[:tipo_visao].to_i == PRODUTOS
				itens = NotaFiscal.select('produtos.codigo_sistema_legado')
													.select('produtos.nome')
													.joins(:produto)
													.where('nota_fiscais.valor >= 0')
													.group('produtos.codigo_sistema_legado, produtos.nome')
			elsif params[:tipo_visao].to_i == UNIDADES
				itens = NotaFiscal.select('unidades.nome')
													.joins(:unidade)
													.where('nota_fiscais.valor >= 0')
													.group('unidades.id')
			end
			
			if params[:data_inicial].present?
				itens = itens.where('nota_fiscais.data_emissao >= ?', params[:data_inicial].to_date)
			end

			if params[:data_final].present?
				itens = itens.where('nota_fiscais.data_emissao <= ?', params[:data_final].to_date)
			end

			if params[:unidade_ids].present? && params[:unidade_ids].reject(&:blank?).present?
				itens = itens.where(unidade_id: params[:unidade_ids].reject(&:blank?))
			end

			if params[:categoria_ids].present? && params[:categoria_ids].reject(&:blank?).present?
				itens = itens.where("produto_entidades.marca IN(#{params[:categoria_ids].reject(&:blank?).join(', ')})")
			end

			if params[:produto_ids].present? && params[:produto_ids].reject(&:blank?).present?
				itens = itens.where(produto_id: params[:produto_ids].reject(&:blank?))
			end

			itens = itens.order(ordenacao)

			if itens.present?
				itens.each do |item|
					(params[:data_inicial].to_date.year..params[:data_final].to_date.year).each do |ano|
						(params[:data_inicial].to_date.month..params[:data_final].to_date.month).each do |mes|
							if params[:tipo_visao].to_i == CATEGORIA
								mensal = NotaFiscal.select('SUM(nota_fiscais.valor) AS vendas_mensal')
															 		 .select('SUM(nota_fiscais.quantidade) AS quantidade_mensal')
																	 .joins(:produto)
										 							 .joins('INNER JOIN de_para_produtos ON de_para_produtos.produto_id = produtos.id')
										 							 .joins('INNER JOIN produto_entidades ON produto_entidades.id = de_para_produtos.produto_entidade_id')
																	 .where('nota_fiscais.valor >= 0')
																	 .where("date_part('MONTH', nota_fiscais.data_emissao) = '#{mes}'")
																	 .where("date_part('YEAR', nota_fiscais.data_emissao) = '#{ano}'")
																	 .where("produto_entidades.marca = '#{item[:marca].strip}'")
								indice = item[:marca]
							elsif params[:tipo_visao].to_i == CLIENTES
								mensal = NotaFiscal.select('SUM(nota_fiscais.valor) AS vendas_mensal')
															 		 .select('SUM(nota_fiscais.quantidade) AS quantidade_mensal')
																	 .joins(:cliente)
																	 .where('nota_fiscais.valor >= 0')
																	 .where("date_part('MONTH', nota_fiscais.data_emissao) = '#{mes}'")
																	 .where("date_part('YEAR', nota_fiscais.data_emissao) = '#{ano}'")
																	 .where("clientes.codigo_sistema_legado = '#{item[:codigo_sistema_legado].strip}'")
																	 .where("clientes.nome_razao_social = '#{item[:nome_razao_social].strip}'")
								indice = "#{item[:codigo_sistema_legado]} - #{item[:nome_razao_social]}"
							elsif params[:tipo_visao].to_i == PRODUTOS
								mensal = NotaFiscal.select('SUM(nota_fiscais.valor) AS vendas_mensal')
															 		 .select('SUM(nota_fiscais.quantidade) AS quantidade_mensal')
																	 .joins(:produto)
																	 .where('nota_fiscais.valor >= 0')
																	 .where("date_part('MONTH', nota_fiscais.data_emissao) = '#{mes}'")
																	 .where("date_part('YEAR', nota_fiscais.data_emissao) = '#{ano}'")
																	 .where("produtos.codigo_sistema_legado = '#{item[:codigo_sistema_legado].strip}'")
																	 .where("produtos.nome = '#{item[:nome].strip}'")
								indice = "#{item[:codigo_sistema_legado]} - #{item[:nome]}"
							elsif params[:tipo_visao].to_i == UNIDADES
								mensal = NotaFiscal.select('SUM(nota_fiscais.valor) AS vendas_mensal')
															 		 .select('SUM(nota_fiscais.quantidade) AS quantidade_mensal')
																	 .joins(:unidade)
																	 .where('nota_fiscais.valor >= 0')
																	 .where("date_part('MONTH', nota_fiscais.data_emissao) = '#{mes}'")
																	 .where("date_part('YEAR', nota_fiscais.data_emissao) = '#{ano}'")
																	 .where("unidades.nome = '#{item[:nome].strip}'")
								indice = item[:nome]
							end

							valor_mensal_vendas = mensal.first[:vendas_mensal].blank? ? 0 : mensal.first[:vendas_mensal].to_f
							valor_mensal_quantidade = mensal.first[:quantidade_mensal].blank? ? 0 : mensal.first[:quantidade_mensal].to_f
							resultado[indice] ||= {}
							resultado[indice][ano] ||= {}
							resultado[indice][ano][mes] ||= {}
							resultado[indice][ano][mes][:vendas_mensal] = valor_mensal_vendas
							resultado[indice][ano][mes][:quantidade_mensal] = valor_mensal_quantidade

							resultado[:totais] ||= {}
							resultado[:totais][ano] ||= {}
							resultado[:totais][ano][mes] ||= {}
							resultado[:totais][ano][mes][:total_vendas] ||= 0
							resultado[:totais][ano][mes][:total_vendas] = resultado[:totais][ano][mes][:total_vendas] + valor_mensal_vendas
							resultado[:totais][ano][mes][:total_quantidade] ||= 0
							resultado[:totais][ano][mes][:total_quantidade] = resultado[:totais][ano][mes][:total_quantidade] + valor_mensal_quantidade
						end
					end
				end
				[true, resultado]
			else
				[false, 'Sem registros encontrados. Verifique os parâmetros da pesquisa.']
			end
		end
	end

end
