module ApplicationHelper
  # Takes the same arguments as javascript_include_tag, and returns an array of
  # paths to javascript assets. This is currently implemented in a horribly
  # hacky way by calling javascript_include_tag and parsing the html it produces
  # by using a regex.
  def javascript_paths(*sources)
    js_tags = javascript_include_tag(*sources)
    js_tags.scan(/src="(.*?)"/).map do |tag|
      tag[0]
    end
  end

  # Takes the same arguments as stylesheet_link_tag, and returns an array of
  # paths to stylesheet assets. This is currently implemented in a horribly
  # hacky way by calling stylesheet_link_tag and parsing the html it
  # produces by using a regex.
  def stylesheet_paths(*sources)
    css_tags = stylesheet_link_tag(*sources)
    css_tags.scan(/href="(.*?)"/).map do |tag|
      tag[0]
    end
  end
end
