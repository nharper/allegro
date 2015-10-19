module PerformersHelper
  # Upcases a name, but preserves lowercase characters in certain cases. Some
  # names (like McCoy) look weird if entirely upcased, and should be "McCOY"
  # instead.
  def name_upcase(name)
    name.split(/(?<=[^a-zA-Z])/).map do |part|
      matches = /[A-Z][^A-Z]*$/.match(part)
      if matches && matches.length > 0
        index = matches.offset(0)[0]
        part.slice(0, index) + part.slice(index..-1).upcase
      else
        part.upcase
      end
    end.join
  end
end
