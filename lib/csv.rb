module CSV
  def self.parse_old(input)
    lines = input.split(/[\r\n]/)
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

  # Special characters:
  # Quote ("): Start or end of quoted-string. Within a quoted-string, two quoted
  #            strings ('""') form an escape sequence for a quote in the
  #            quoted-string.
  # Comma (,): Separator between fields
  # Newline (\r, \n, or \r\n): Line separator. Empty lines are ignored.
  def self.parse(input)
    out = []
    quoted = false
    fields = []
    line = []
    field = ''
    last_char_quote = false
    input.each_char do |c|
      if c == '"'
        if !quoted
          quoted = true
          next
        end
        last_char_quote = !last_char_quote
        if !last_char_quote
          field += '"'
        end
        next
      end
      if quoted && !last_char_quote
        field += c
        next
      end
      if last_char_quote && quoted
        quoted = false
        last_char_quote = false
      end
      # Handle the field separator
      if c == ','
        line << field
        field = ''
        next
      end
      # Handle a newline
      if c == "\r" || c == "\n"
        if field.length || line.length
          line << field
          out << line
          field = ''
          line = []
        end
        next
      end
      # Handle any other character
      field += c
    end
    # Handle the last record
    if field.length > 0 || line.length > 0
      line << field
      out << line
    end
    return out
  end
end
