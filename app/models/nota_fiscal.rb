class NotaFiscal < ActiveRecord::Base


   attr_accessible :numero_documento
   attr_accessible :codigo_sistema_legado
   attr_accessible :data_emissao
   attr_accessible :vendedor_id
   attr_accessible :cliente_id
   attr_accessible :produto_id
   attr_accessible :quantidade
   attr_accessible :valor
   attr_accessible :valor_desconto
   attr_accessible :valor_porcentagem_desconto
   attr_accessible :descricao
   attr_accessible :outros_campos
   attr_accessible :unidade_id
   attr_accessible :active

   belongs_to :unidade
   belongs_to :vendedor
   belongs_to :cliente
   belongs_to :produto

   validates :numero_documento, presence: true,
                                length: { maximum: 255 }
                                # uniqueness: { case_sensitive: false, scope: [:unidade_id] }
   validates :data_emissao, presence: true
   validates :quantidade, presence: true,
                          numericality: { greater_than: 0 }
   validates :valor, presence: true,
                     inclusion: 0.00..99999999999999.99
  # validates :valor_desconto, inclusion: 0.00..99999999999999.99
  # validates :valor_porcentagem_desconto, inclusion: 0.00..99999999999999.99
   validates :vendedor, presence: true
   validates :cliente, presence: true
   validates :produto, presence: true
   validates :unidade, presence: true

   def calcula_valor_total_item
      # (valor * quantidade) rescue 0.00
      valor rescue 0.00
   end

end
