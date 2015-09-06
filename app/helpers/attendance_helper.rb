module AttendanceHelper
  def record_tag(tag_name, record)
    case record.present
    when true
      symbol = '✓'
      display_class = 'present'
    when false
      symbol = '✗'
      display_class = 'absent'
    else
      symbol = '?'
      display_class = 'unknown'
    end
    attrs = {:class => ['record', display_class]}
    if record.notes
      attrs[:title] = record.notes
    end
    return content_tag(tag_name, attrs) {symbol}
  end
end
