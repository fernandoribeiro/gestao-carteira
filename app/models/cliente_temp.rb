# encoding: UTF-8

class ClienteTemp < ActiveRecord::Base

  attr_accessible :error_messages

  serialize :error_messages, Hash

  belongs_to :unidade


  def self.pesquisa(entidade, params)
    conditions = []
    variaveis  = []

    conditions << 'unidades.entidade_id = ?'
    variaveis  << entidade.id
    conditions << 'cliente_temps.sent_to_master = ?'
    variaveis  << false
    conditions << 'cliente_temps.error_messages IS NOT NULL'

    if params[:texto].present?
      conditions << '(cliente_temps.nome_razao_social ILIKE ? OR
                      cliente_temps.codigo_sistema_legado ILIKE ?)'
      2.times{ variaveis << params[:texto].like }
    end

    ClienteTemp.joins(:unidade)
               .where([conditions.join(' AND ')] + variaveis)
               .order('cliente_temps.nome_razao_social, cliente_temps.codigo_sistema_legado')
  end

  def self.popula_tabela_master
    ClienteTemp.where(sent_to_master: false)
               .limit(50000)
               .each do |cliente_temp|
      cliente = Cliente.where('UPPER(codigo_sistema_legado) = ? AND
                               UPPER(nome_razao_social) = ? AND
                               unidade_id = ?',
                               (cliente_temp.codigo_sistema_legado.upcase rescue nil),
                               (cliente_temp.nome_razao_social.upcase rescue nil),
                               (cliente_temp.unidade_id rescue nil)
                             )
                        .first
      ### CREATE
      if cliente.blank?
        params = {
                    codigo_sistema_legado: (cliente_temp.codigo_sistema_legado.upcase rescue nil),
                    nome_razao_social: (cliente_temp.nome_razao_social.upcase rescue nil),
                    tipo_pessoa: (cliente_temp.tipo_pessoa.upcase rescue nil),
                    cidade_nome: (cliente_temp.cidade_nome.upcase rescue nil),
                    estado: (cliente_temp.estado.upcase rescue nil),
                    email: (cliente_temp.email.upcase rescue nil),
                    telefone: (cliente_temp.telefone.upcase rescue nil),
                    outros_campos: (cliente_temp.outros_campos.upcase rescue nil),
                    unidade_id: (cliente_temp.unidade_id rescue nil),
                    active: true
                  }
        new_cliente = Cliente.new(params)
        if new_cliente.save
          cliente_temp.update_column(:error_messages, nil)
          cliente_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          new_cliente.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          cliente_temp.update_column(:error_messages, erros.to_yaml)
          cliente_temp.update_column(:sent_to_master, false)
        end
      ### UPDATE
      else
        params = {
                    codigo_sistema_legado: (cliente_temp.codigo_sistema_legado.upcase rescue nil),
                    nome_razao_social: (cliente_temp.nome_razao_social.upcase rescue nil),
                    tipo_pessoa: (cliente_temp.tipo_pessoa.upcase rescue nil),
                    cidade_nome: (cliente_temp.cidade_nome.upcase rescue nil),
                    estado: (cliente_temp.estado.upcase rescue nil),
                    email: (cliente_temp.email.upcase rescue nil),
                    telefone: (cliente_temp.telefone.upcase rescue nil),
                    outros_campos: (cliente_temp.outros_campos.upcase rescue nil),
                    unidade_id: (cliente_temp.unidade_id rescue nil),
                    active: true
                  }

        if cliente.update_attributes(params)
          cliente_temp.update_column(:error_messages, nil)
          cliente_temp.update_column(:sent_to_master, true)
        else
          erros ||= {}
          cliente.errors.messages.each do |erro|
            erros[erro.first] = erro.last.join(';')
          end
          cliente_temp.update_column(:error_messages, erros.to_yaml)
          cliente_temp.update_column(:sent_to_master, false)
        end
      end
    end
  end

end
