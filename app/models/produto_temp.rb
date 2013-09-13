# encoding: UTF-8

class ProdutoTemp < ActiveRecord::Base

  attr_accessible :error_messages

  serialize :error_messages, Hash

  belongs_to :unidade


  def self.pesquisa(entidade, params)
    conditions = []
    variaveis  = []

    conditions << 'unidades.entidade_id = ?'
    variaveis  << entidade.id
    conditions << 'produto_temps.sent_to_master = ?'
    variaveis  << false
    conditions << 'produto_temps.error_messages IS NOT NULL'

    if params[:texto].present?
      conditions << '(produto_temps.nome ILIKE ? OR
                      produto_temps.codigo_sistema_legado ILIKE ?)'
      2.times{ variaveis << params[:texto].like }
    end

    ProdutoTemp.joins(:unidade)
               .where([conditions.join(' AND ')] + variaveis)
               .order('produto_temps.nome, produto_temps.codigo_sistema_legado')
  end

  def self.popula_tabela_master
    ProdutoTemp.where(sent_to_master: false)
               .limit(50000)
               .each do |produto_temp|
      produto = Produto.where('UPPER(codigo_sistema_legado) = ? AND
                               UPPER(nome) = ? AND
                               unidade_id = ?',
                               (produto_temp.codigo_sistema_legado.upcase rescue nil),
                               (produto_temp.nome.upcase rescue nil),
                               (produto_temp.unidade_id rescue nil)
                             )
                       .first
      ### CREATE
      if produto.blank?
        params = {
                    codigo_sistema_legado: (produto_temp.codigo_sistema_legado.upcase rescue nil),
                    nome: (produto_temp.nome.upcase rescue nil),
                    outros_campos: (produto_temp.outros_campos.upcase rescue nil),
                    unidade_id: (produto_temp.unidade_id rescue nil),
                    active: true
                  }
        new_produto = Produto.new(params)
        if new_produto.save
          produto_temp.update_column(:error_messages, nil)
          produto_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          new_produto.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          produto_temp.update_column(:error_messages, erros.to_yaml)
          produto_temp.update_column(:sent_to_master, false)
        end
      ### UPDATE
      else
        params = {
                    codigo_sistema_legado: (produto_temp.codigo_sistema_legado.upcase rescue nil),
                    nome: (produto_temp.nome.upcase rescue nil),
                    outros_campos: (produto_temp.outros_campos.upcase rescue nil),
                    unidade_id: (produto_temp.unidade_id rescue nil),
                    active: true
                  }

        if produto.update_attributes(params)
          produto_temp.update_column(:error_messages, nil)
          produto_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          produto.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          produto_temp.update_column(:error_messages, erros.to_yaml)
          produto_temp.update_column(:sent_to_master, false)
        end
      end
    end
  end

end
