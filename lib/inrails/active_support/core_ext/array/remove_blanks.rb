class Array
  def remove_blanks
    inject([]) do |mem, val|
      case val
      when Array
        mem << val.remove_blanks
      when Hash
        mem << val.remove_blanks
      else
        mem << val
      end unless val.blank?

      mem
    end
  end
end
