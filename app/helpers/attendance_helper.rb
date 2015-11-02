module AttendanceHelper
  def record_tag(tag_name, record, rehearsal)
    case record.present
    when true
      symbol = "\u2713"
      display_class = 'present'
    when false
      symbol = "\u2717"
      display_class = 'absent'
    else
      symbol = '?'
      display_class = 'unknown'
    end
    symbol = symbol * rehearsal.weight
    attrs = {
      :class => ['record', display_class],
      :title => rehearsal.display_name
    }
    if record.notes
      attrs[:title] = record.notes
    end
    return content_tag(tag_name, attrs) {symbol}
  end
end
