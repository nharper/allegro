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
    i = -1
    while i < input.length-1
      i += 1
      # Handle encountering a quote symbol
      if input[i] == '"'
        # If we see a quote, but the next char is also a quote, then this is
        # an escape sequence, and we should emit a quote (but not toggle state).
        if i + 1 < input.length && input[i+1] == '"' && quoted
          field += '"'
          i += 1
        else
          quoted = !quoted
        end
        next
      end
      # Emit the next character while we're still in a quote
      if quoted
        field += input[i]
        next
      end
      # Handle the field separator
      if input[i] == ','
        line << field.force_encoding(Encoding::UTF_8)
        field = ''
        next
      end
      # Handle a newline
      if input[i] == "\r" || input[i] == "\n"
        if field.length || line.length
          line << field.force_encoding(Encoding::UTF_8)
          out << line
          field = ''
          line = []
        end
        next
      end
      # Handle any other character
      field += input[i]
    end
    # Handle the last record
    if field.length > 0 || line.length > 0
      line << field.force_encoding(Encoding::UTF_8)
      out << line
    end
    return out
  end
end
