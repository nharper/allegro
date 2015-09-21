module CSV
  def self.parse(input)
    lines = input.split("\r\n")
    out = []
    lines.each do |line|
      quoted = false
      fields = []
      field = ''
      for i in 0..(line.length - 1)
        if line[i] == '"'
          if quoted
            quoted = false
          else
            quoted = true
          end
          next
        end
        if line[i] == ',' && quoted == false
          fields << field
          field = ''
          next
        end
        field += line[i]
      end
      fields << field
      out << fields
    end
    return out
  end
end
