# encoding: UTF-8

class NotaFiscalTemp < ActiveRecord::Base

  attr_accessible :error_messages

  serialize :error_messages, Hash

  belongs_to :unidade


  def self.pesquisa(entidade, params)
    conditions = []
    variaveis = []

    conditions << 'unidades.entidade_id = ?'
    variaveis  << entidade.id
    conditions << 'nota_fiscal_temps.sent_to_master = ?'
    variaveis  << false
    conditions << 'nota_fiscal_temps.error_messages IS NOT NULL'

    if params[:texto].present?
      conditions << '(nota_fiscal_temps.numero_documento ILIKE ? OR
                      nota_fiscal_temps.cliente_id ILIKE ? OR
                      nota_fiscal_temps.produto_id ILIKE ? OR
                      nota_fiscal_temps.vendedor_id ILIKE ?)'
      4.times{ variaveis << params[:texto].like }
    end

    NotaFiscalTemp.joins(:unidade)
                  .where([conditions.join(' AND ')] + variaveis)
                  .order('nota_fiscal_temps.numero_documento,
                          nota_fiscal_temps.data_emissao,
                          nota_fiscal_temps.cliente_id,
                          nota_fiscal_temps.produto_id,
                          nota_fiscal_temps.vendedor_id')
  end


  def self.popula_tabela_master
    NotaFiscalTemp.where(sent_to_master: false)
                  .order(:numero_documento)
                  .limit(70000)
                  .each do |nota_fiscal_temp|
      nota_fiscal = NotaFiscal.where('UPPER(numero_documento) = ? AND
                                      numero_item = ? AND
                                      produto_id = ? AND
                                      quantidade = ? AND
                                      unidade_id = ?',
                                      (nota_fiscal_temp.numero_documento.upcase rescue nil),
                                      (nota_fiscal_temp.numero_item rescue nil),
                                      (nota_fiscal_temp.produto_id rescue nil),
                                      (nota_fiscal_temp.quantidade rescue nil),
                                      (nota_fiscal_temp.unidade_id rescue nil)
                                    )
                              .first
      ### CREATE
      if nota_fiscal.blank?
        params = {
                    numero_documento: (nota_fiscal_temp.numero_documento.upcase rescue nil),
                    codigo_sistema_legado: (nota_fiscal_temp.codigo_sistema_legado.upcase rescue nil),
                    data_emissao: (nota_fiscal_temp.data_emissao.to_date rescue nil),
                    vendedor_id: (Vendedor.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.vendedor_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    cliente_id: (Cliente.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.cliente_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    produto_id: (Produto.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.produto_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    quantidade: (nota_fiscal_temp.quantidade rescue nil),
                    valor: (nota_fiscal_temp.valor rescue nil),
                    valor_desconto: (nota_fiscal_temp.valor_desconto rescue nil),
                    valor_porcentagem_desconto: (nota_fiscal_temp.valor_porcentagem_desconto rescue nil),
                    descricao: (nota_fiscal_temp.descricao.upcase rescue nil),
                    outros_campos: (nota_fiscal_temp.outros_campos.upcase rescue nil),
                    unidade_id: (nota_fiscal_temp.unidade_id rescue nil),
                    active: true
                  }
        new_nota_fiscal = NotaFiscal.new(params)
        if new_nota_fiscal.save(:validate=>false)
          nota_fiscal_temp.update_column(:error_messages, nil)
          nota_fiscal_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          new_nota_fiscal.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          nota_fiscal_temp.update_column(:error_messages, erros.to_yaml)
          nota_fiscal_temp.update_column(:sent_to_master, false)
        end
      ### UPDATE
      else
        params = {
                    numero_documento: (nota_fiscal_temp.numero_documento.upcase rescue nil),
                    codigo_sistema_legado: (nota_fiscal_temp.codigo_sistema_legado.upcase rescue nil),
                    data_emissao: (nota_fiscal_temp.data_emissao.to_date rescue nil),
                    vendedor_id: (Vendedor.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.vendedor_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    cliente_id: (Cliente.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.cliente_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    produto_id: (Produto.find_by_codigo_sistema_legado_and_unidade_id(nota_fiscal_temp.produto_id, nota_fiscal_temp.unidade_id).id rescue nil),
                    quantidade: (nota_fiscal_temp.quantidade rescue nil),
                    valor: (nota_fiscal_temp.valor rescue nil),
                    valor_desconto: (nota_fiscal_temp.valor_desconto rescue nil),
                    valor_porcentagem_desconto: (nota_fiscal_temp.valor_porcentagem_desconto rescue nil),
                    descricao: (nota_fiscal_temp.descricao.upcase rescue nil),
                    outros_campos: (nota_fiscal_temp.outros_campos.upcase rescue nil),
                    unidade_id: (nota_fiscal_temp.unidade_id rescue nil),
                    active: true
                  }

        if nota_fiscal.update_attributes(params)
          nota_fiscal_temp.update_column(:error_messages, nil)
          nota_fiscal_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          nota_fiscal.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          nota_fiscal_temp.update_column(:error_messages, erros.to_yaml)
          nota_fiscal_temp.update_column(:sent_to_master, false)
        end
      end
    end
  end

end
