#encoding: UTF-8

class GraficoDistribuidor < ActiveRecord::Base

	def self.ranking_clientes_quantidade(params, current_usuario)
		data_inicial = Date.new(params[:ano].to_i, params[:mes].to_i, 1)
		data_final = data_inicial.to_date.end_of_month
		unidade_ids = current_usuario.entidade.unidades.pluck(:id)

		itens = NotaFiscal.select('clientes.codigo_sistema_legado')
											.select('clientes.nome_razao_social')
											.select('COUNT(clientes.codigo_sistema_legado) AS quantidade')
											.joins(:cliente)
											.where('data_emissao >= ?', data_inicial)
											.where('data_emissao <= ?', data_final)
											.where(unidade_id: unidade_ids)
											.group('clientes.codigo_sistema_legado, clientes.nome_razao_social')
											.order('COUNT(clientes.codigo_sistema_legado) DESC, clientes.nome_razao_social ASC')
											.limit(10)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', '')
		data_table.new_column('number', '')
		data_table.add_rows(itens.length)
		itens.each_with_index do |item, index|
			data_table.set_cell(index, 0, item[:nome_razao_social])
			data_table.set_cell(index, 1, item[:quantidade])
		end
 
		opts = { width: 600, height: 300, title: 'Ranking de Clientes (Quantidade) - TOP 10',
						 vAxis: {title: 'Clientes', titleTextStyle: {color: 'red'}},
						 hAxis: {title: 'Quantidade', titleTextStyle: {color: 'red'}}
					 }
		@chart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)
 	end

	def self.ranking_clientes_faturamento(params, current_usuario)
		data_inicial = Date.new(params[:ano].to_i, params[:mes].to_i, 1)
		data_final = data_inicial.to_date.end_of_month
		unidade_ids = current_usuario.entidade.unidades.pluck(:id)

		itens = NotaFiscal.select('clientes.codigo_sistema_legado')
											.select('clientes.nome_razao_social')
											.select('SUM(nota_fiscais.valor) AS faturamento')
											.joins(:cliente)
											.where('data_emissao >= ?', data_inicial)
											.where('data_emissao <= ?', data_final)
											.where(unidade_id: unidade_ids)
											.group('clientes.codigo_sistema_legado, clientes.nome_razao_social')
											.order('SUM(nota_fiscais.valor) DESC')
											.limit(10)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', '')
		data_table.new_column('number', '')
		data_table.add_rows(itens.length)
		itens.each_with_index do |item, index|
			data_table.set_cell(index, 0, item[:nome_razao_social])
			data_table.set_cell(index, 1, item[:faturamento].to_f)
		end
 
		opts = { width: 600, height: 300, title: 'Ranking de Clientes (Faturamento) - TOP 10',
						 is3D:true,
						 vAxis: {title: 'Clientes', titleTextStyle: { color: 'red' }},
						 hAxis: {title: 'Faturamento', titleTextStyle: { color: 'red' }},
						 colors: ['green']
					 }
		@chart = GoogleVisualr::Interactive::BarChart.new(data_table, opts)
 	end

	def self.ranking_produtos_quantidade(params, current_usuario)
		data_inicial = Date.new(params[:ano].to_i, params[:mes].to_i, 1)
		data_final = data_inicial.to_date.end_of_month
		unidade_ids = current_usuario.entidade.unidades.pluck(:id)

		itens = NotaFiscal.select('produtos.codigo_sistema_legado')
											.select('produtos.nome')
											.select('COUNT(produtos.codigo_sistema_legado) AS quantidade')
											.joins(:produto)
											.where('data_emissao >= ?', data_inicial)
											.where('data_emissao <= ?', data_final)
											.where(unidade_id: unidade_ids)
											.group('produtos.codigo_sistema_legado, produtos.nome')
											.order('COUNT(produtos.codigo_sistema_legado) DESC, produtos.nome ASC')
											.limit(10)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', '')
		data_table.new_column('number', '')
		data_table.add_rows(itens.length)
		itens.each_with_index do |item, index|
			data_table.set_cell(index, 0, item[:nome])
			data_table.set_cell(index, 1, item[:quantidade].to_f)
		end
 
		opts = { width: 600, height: 300, title: 'Ranking de Produtos (Quantidade) - TOP 10',
						 is3D: true, legend: 'bottom',
						 vAxis: {title: 'Produtos', titleTextStyle: { color: 'red' }},
						 hAxis: {title: 'Quantidade', titleTextStyle: { color: 'red' }}
					 }
		@chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)
 	end

	def self.ranking_produtos_faturamento(params, current_usuario)
		data_inicial = Date.new(params[:ano].to_i, params[:mes].to_i, 1)
		data_final = data_inicial.to_date.end_of_month
		unidade_ids = current_usuario.entidade.unidades.pluck(:id)

		itens = NotaFiscal.select('produtos.codigo_sistema_legado')
											.select('produtos.nome')
											.select('SUM(nota_fiscais.valor) AS faturamento')
											.joins(:produto)
											.where('data_emissao >= ?', data_inicial)
											.where('data_emissao <= ?', data_final)
											.where(unidade_id: unidade_ids)
											.group('produtos.codigo_sistema_legado, produtos.nome')
											.order('SUM(nota_fiscais.valor) DESC')
											.limit(10)

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', '')
		data_table.new_column('number', '')
		data_table.add_rows(itens.length)
		itens.each_with_index do |item, index|
			data_table.set_cell(index, 0, item[:nome])
			data_table.set_cell(index, 1, item[:faturamento].to_f)
		end
 
		opts = { width: 600, height: 300, title: 'Ranking de Produtos (Faturamento) - TOP 10',
						 is3D: true, legend: 'bottom',
						 vAxis: {title: 'Produtos', titleTextStyle: { color: 'red' }},
						 hAxis: {title: 'Faturamento', titleTextStyle: { color: 'red' }}
					 }
		@chart = GoogleVisualr::Interactive::PieChart.new(data_table, opts)
 	end

 	def self.vendas_por_distribuidor(params, current_usuario)
		data_inicial = Date.new(params[:ano].to_i, params[:mes].to_i, 1)
		data_final = data_inicial.to_date.end_of_month
		unidade_ids = current_usuario.entidade.unidades.pluck(:id)

		itens = NotaFiscal.select('unidades.nome')
											.select('SUM(nota_fiscais.valor) AS total_vendas')
											.joins(:unidade)
											.where('data_emissao >= ?', data_inicial)
											.where('data_emissao <= ?', data_final)
											.where(unidade_id: unidade_ids)
											.group('unidades.id')
											.order('SUM(nota_fiscais.valor) DESC')

		data_table = GoogleVisualr::DataTable.new
		data_table.new_column('string', '')
		data_table.new_column('number', '')
		data_table.add_rows(itens.length)
		itens.each_with_index do |item, index|
			data_table.set_cell(index, 0, item[:nome])
			data_table.set_cell(index, 1, item[:total_vendas].to_f)
		end
 
		opts = { width: 1200, height: 300, title: 'Vendas por Distribuidor',
						 vAxis: {title: 'Distribuidor', titleTextStyle: {color: 'red'}},
						 hAxis: {title: 'Total de Vendas', titleTextStyle: {color: 'red'}},
						 colors: ['orange']
					 }
		@chart = GoogleVisualr::Interactive::ColumnChart.new(data_table, opts)
 	end

end
