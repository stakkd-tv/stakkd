ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  fragment = Nokogiri::HTML::DocumentFragment.parse(html_tag)
  element = fragment.children.first

  if element
    element.set_attribute("data-error", "true")
    fragment.to_html.html_safe
  else
    html_tag.html_safe
  end
end
