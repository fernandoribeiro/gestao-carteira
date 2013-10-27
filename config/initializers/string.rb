class String

  def like
    "%#{self}%"
  end

  def trata_cnpj
  	self.gsub(/\W/, '') rescue ''
  end

  def trata_data
  	self.to_date.strftime('%Y%m%d') rescue ''
  end

  def trata_valores(tamanho)
  	valor = self[0..(tamanho-2)].rjust((tamanho-1), '0')
  	self.to_f >= 0 ? "+#{valor}" : "-#{valor}"
  end

  def trata_valores_42(tamanho)
    valor = self[0..(tamanho-1)].rjust((tamanho-0), '0')
    self.to_f >= 0 ? "#{valor}" : "#{valor}"
  end

end
