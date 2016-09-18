require 'unicode_utils/upcase'

module PerformersHelper
  # Upcases a name, but preserves lowercase characters in certain cases. Some
  # names (like McCoy) look weird if entirely upcased, and should be "McCOY"
  # instead.
  def name_upcase(name)
    name.split.map do |part|
      matches = /[A-Z][^A-Z]*$/.match(part)
      if matches && matches.length > 0
        index = matches.offset(0)[0]
        UnicodeUtils.upcase(part.slice(0, index) + part.slice(index..-1))
      else
        UnicodeUtils.upcase(part)
      end
    end.inject('') do |a, b|
      a + ' ' + b
    end
  end
end
