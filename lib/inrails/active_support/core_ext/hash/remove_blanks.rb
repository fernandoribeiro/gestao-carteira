class Hash
  def remove_blanks
    inject({}) do |mem, (key, val)|
      case val
      when Array
        mem[key] = val.remove_blanks
      when Hash
        mem[key] = val.remove_blanks
      else
        mem[key] = val
      end unless val.blank?

      mem
    end
  end
end
