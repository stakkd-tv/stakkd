ActionView::Base.field_error_proc = proc do |html_tag, _instance|
  fragment = Nokogiri::HTML::DocumentFragment.parse(html_tag)
  element = fragment.children.first

  if element
    element.set_attribute("data-field-error", "true")
    if element.name != "label"
      new_node = Nokogiri::XML::Node.new("small", fragment)
      field_name = _instance.instance_variable_get(:@method_name).humanize
      new_node.content = "#{field_name} #{_instance.error_message.to_sentence}".humanize
      new_node.set_attribute("class", "mt-2 inline-block")
      element.add_next_sibling(new_node)
    end

    fragment.to_html.html_safe
  else
    html_tag.html_safe
  end
end
