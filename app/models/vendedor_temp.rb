# encoding: UTF-8

class VendedorTemp < ActiveRecord::Base

  attr_accessible :error_messages

  serialize :error_messages, Hash

  belongs_to :unidade


  def self.pesquisa(entidade, params)
    conditions = []
    variaveis  = []

    conditions << 'unidades.entidade_id = ?'
    variaveis  << entidade.id
    conditions << 'vendedor_temps.sent_to_master = ?'
    variaveis  << false
    conditions << 'vendedor_temps.error_messages IS NOT NULL'

    if params[:texto].present?
      conditions << '(vendedor_temps.nome ILIKE ? OR
                      vendedor_temps.codigo_sistema_legado ILIKE ?)'
      2.times{ variaveis << params[:texto].like }
    end

    VendedorTemp.joins(:unidade)
                .where([conditions.join(' AND ')] + variaveis)
                .order('vendedor_temps.nome, vendedor_temps.codigo_sistema_legado')
  end

  def self.popula_tabela_master
    VendedorTemp.where(sent_to_master: false)
                .limit(50000)
                .each do |vendedor_temp|
      vendedor = Vendedor.where('UPPER(codigo_sistema_legado) = ? AND
                                 UPPER(nome) = ? AND
                                 unidade_id = ?',
                                 (vendedor_temp.codigo_sistema_legado.upcase rescue nil),
                                 (vendedor_temp.nome.upcase rescue nil),
                                 (vendedor_temp.unidade_id rescue nil)
                               )
                         .first
      ### CREATE
      if vendedor.blank?
        params = {
                    codigo_sistema_legado: (vendedor_temp.codigo_sistema_legado.upcase rescue nil),
                    nome: (vendedor_temp.nome.upcase rescue nil),
                    unidade_id: (vendedor_temp.unidade_id rescue nil),
                    active: true
                  }
        new_vendedor = Vendedor.new(params)
        if new_vendedor.save
          vendedor_temp.update_column(:error_messages, nil)
          vendedor_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          new_vendedor.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          vendedor_temp.update_column(:error_messages, erros.to_yaml)
          vendedor_temp.update_column(:sent_to_master, false)
        end
      ### UPDATE
      else
        params = {
                    codigo_sistema_legado: (vendedor_temp.codigo_sistema_legado.upcase rescue nil),
                    nome: (vendedor_temp.nome.upcase rescue nil),
                    unidade_id: (vendedor_temp.unidade_id rescue nil),
                    active: true
                  }
        if vendedor.update_attributes(params)
          vendedor_temp.update_column(:error_messages, nil)
          vendedor_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          vendedor.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          vendedor_temp.update_column(:error_messages, erros.to_yaml)
          vendedor_temp.update_column(:sent_to_master, false)
        end
      end
    end
  end

end
