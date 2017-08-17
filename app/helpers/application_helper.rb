
module ApplicationHelper

  def self.included(klass)
    Rails.logger.debug("ApplicationHelper included By #{klass.name}, self: #{self.name}")
  end

  def flash_message(type, text)
    if flash[type].present? and flash[type].is_a?(Array)
      flash[type] << text
    elsif flash[type].present? and flash[type].is_a?(String)
      flash[type] = [flash[type], text]
    else
      flash[type] = [text]
    end
  end

  def menu_active?(menu_link)
    active = false
    page_access = "#{controller_name}/#{action_name}"

    if menu_link.is_a? Array
      active = menu_link.include?(page_access)
    else
      active = page_access.include?(menu_link)
    end
    active ? 'active' : ''
  end

  def logo(logo_id="logo")
    logo = image_tag("LinuxSMP.png", id: logo_id, alt: "SknServices", class: "brand-image")
  end

  # Returns the Gravatar (http://gravatar.com/) for the given employee.
  def gravatar_for(user, options = { :size => 75 })
    gravatar_image_tag(user.email.strip,  :alt => h(user.name),
                       :class => 'gravatar round',
                       :gravatar => options)
  end

  # Generate one or more <td>icons for each input
  # ex: choose_column_icons(true,true,true,false,true)
  #
  # Light
  # yes .glyphicon .glyphicon-ok-circle
  #  no .glyphicon .glyphicon-remove-circle
  # Dark
  # yes .glyphicon .glyphicon-ok-sign
  #  no .glyphicon .glyphicon-remove-sign
  def choose_column_icons(*show)
    #show is_a?(Array)
    out = show.inject([]) do |res,item|
      icon = (item ? "glyphicon-ok-circle" : "glyphicon-remove-circle")
      res << content_tag(:td, tag(:span, class: ["glyphicon", icon, "btn-lg"]), class: "text-center")
    end
    raw out.join()
  end

  def nav_link(link_text, link_path, http_method=nil)
    class_name = current_page?(link_path) ? 'active' : ''
    opts = http_method.nil? ? {method: http_method} : {}

    content_tag(:li, class: class_name) do
      link_to(link_text,link_path, opts)
    end
  end

  def nav_link_icon(icon, link_text, link_path, http_method=nil)
    class_name = current_page?(link_path) ? 'active' : ''
    opts = http_method.nil? ? {method: http_method} : {}

    content_tag(:li, class: class_name) do
      link_to(link_path, opts) do
        content_tag(:span) do
          keep = content_tag("i", nil, {class: "glyphicon #{icon}"})
          keep += "&nbsp;#{link_text}".html_safe
          keep
        end
      end
    end
  end

  ### Converts named routes to string
  #  Basic '/some/hardcoded/string/path'
  #        '[:named_route_path]'
  #        '[:named_route_path, {options}]'
  #        '[:named_route_path, {options}, '?query_string']'
  #
  # Advanced ==> {engine: :demo,
  #               path: :demo_profiles_path,
  #               options: {id: 111304},
  #               query: '?query_string'
  #              }
  #              {engine: :sym, path: :sym , options: {}, query: ''}
  def page_action_paths(paths)
    case paths
      when Array
        case paths.size
          when 1
            send( paths[0] )
          when 2
            send( paths[0], paths[1] )
          when 3
            rstr = send( paths[0], paths[1] )
            rstr + paths[2]
        end

      when Hash
        rstr = send(paths[:engine]).send(paths[:path], paths.fetch(:options,{}) )
        rstr + paths.fetch(:query, '')

      when String
        paths
    end
  rescue
    '#page_action_error'
  end

  def do_page_actions
    if @page_controls and @page_controls.page_actions?
      PageActionsBuilder.new(@page_controls.hash_from(:page_actions), self, false).to_s
    end
  end

  def string_to_currency(s, *opts)
    value = s.to_s.gsub(/$, /,'')
    precision = 0
    negative_format = "(%u%n)"
    opts.each do |opt|
      if opt.is_a?(Hash)
        precision = opt[:precision] if opt.has_key?(:precision)
        negative_format = opt[:negative_format] if opt.has_key?(:negative_format)
      end
    end
    is_a_number?(value) ? number_to_currency(value, precision: precision, negative_format: negative_format ) : s
  end

  def is_a_number?(s)
    return true if [Fixnum, Float].include?(s.class)
    s.to_s.strip.match(/\A[+-]?\d+?(\.\d+)?\Z/) == nil ? false : true
  end

  def snake_case(value)
    value.downcase.gsub(/\s+/,'_')
  end

end # End module
