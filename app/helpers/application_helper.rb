
module ApplicationHelper

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

  def logo
    logo = image_tag("AvatarSMP.gif", alt: "Skoona Services", class: "img-responsive")
  end

  # Return title on a per-page basis.
  def full_title(page_title)
    base_title = "Time and it's Cost"
    if page_title.empty?
      base_title
    else
      "#{base_title} | #{page_title}"
    end
  end

  # Returns the Gravatar (http://gravatar.com/) for the given employee.
  def gravatar_for(user, options = { :size => 50 })
    gravatar_image_tag(user.email.strip,  :alt => h(user.name),
                       :class => 'gravatar round',
                       :gravatar => options)
  end

  def password_service
    @ct_password_service ||= PasswordService.new({controller: self})
    yield @ct_password_service if block_given?
    @ct_password_service
  end

  def nav_link(link_text, link_path, http_method=nil)
    class_name = current_page?(link_path) ? 'active' : ''

    content_tag(:li, class: class_name) do
      if http_method
        link_to(link_text, link_path, method: http_method)
      else
        link_to(link_text, link_path)
      end
    end
  end
  
end # End module
