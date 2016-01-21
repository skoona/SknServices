##
# app/beans/page_actions_builder.rb
#
# Build HTML for PageActions dropdown menus
#
########
# link_to macro takes three params(hashes), path, text, html_options_hash
# link_to(text, path, html_options_hash, &block)
#         p1,   p2,   p3
#
# [{},{}]    = Two Items
# [{},{},[{},{}]]
#
## usage
# page_actions = []
# page_actions << {
# a0      icon_klass: 'desired-glyphicon-class',
# a0      icon_post_klass: 'desired-glyphicon-class',
# a1      item_type: ':header|:divider'                :submenu, :submenu_hdr coming later
#
# p1      text: "text on button",
# p2      path: :see page_action_paths helper,
#
# p3      id: 'id-string',
# p3      klass: 'desired-bootstrap-class',             btn-default, btn-info, btn-lg
# p3      method: 'html-method',
# p3      data: { myKey: value, 'my-keys' => values, toggle: "modal" },
# }
########
#
##

class PageActionsBuilder

  # take what should be an Array, and the Controller or view instance
  def initialize(bundle, templater)
    @bundle = bundle
    @service = templater
  end

  delegate :content_tag, :tag, :action_name, :h, to: :view


  def to_s
    @service.raw generate
  end

  def generate

  end


  def build_menu_html(control, text, path, html_options)
    case control
      when :li_header
        content_tag(:li, content_tag(:span, text), html_options)
        #
      when :li_divider
        content_tag(:li,nil,class: "divider")
        #
      when :li_icon
        content_tag(:li) do
          content_tag(:span, class: "glyphicon") +
            content_tag(:a, text, html_options )
        end
        #
      when :li_icon_post
        content_tag(:li) do
          content_tag(:a, text, html_options ) +
            content_tag(:span, class: "glyphicon")
        end
        #
      when :li_text_only
        content_tag(:li, content_tag(:span, text, html_options))
        #
      when :li_submenu
        #
      else
        # no-op
    end
  end

end

# StandAlone Button

#<div class="pull-right">
#   <div class="dropdown" role="group">
#       <a id="dLabel" role="button" class="btn btn-primary" href="/pages/home">
#           <span class="glyphicon glyphicon-home"></span>
#           <span>Actions</span>
#           <span class="glyphicon glyphicon-cog"></span>
#       </a>
#   </div>
#</div>


# Regular Dropdown Menu

#<div class="dropdown">
#   <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-primary" data-target="#" href="#">
#       <span>Actions</span>
#       <span class="caret"></span>
#   </a>
#   <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
#       <li>
#           <a href="#">First level</a>
#       </li>
#       <li>
#           <a href="#">First Level</a>
#       </li>
#       <li class="divider"></li>
#       <li class="dropdown-header">
#           <span>TEXT</span>
#       </li>
#       <li>
#           <a href="#">First Level</a>
#       </li>
#   </ul>
#</div>


# Multi Level Dropdown Menu

#<div class="dropdown">
#   <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-primary" data-target="#" href="#">
#       Actions
#       <span class="caret"></span>
#   </a>
#   <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
#       <li>
#           <a href="#">First level</a>
#       </li>
#       <li>
#           <a href="#">First Level</a>
#       </li>
#       <li class="divider"></li>
#       <li class="dropdown-header">
#           <a href="#">First Level</a>
#       </li>
#       <li class="dropdown-header">
#           TEXT
#       </li>

#       <li class="dropdown-submenu">
#           <a tabindex="-1" href="#">Header for 2nd Level</a>

#           <ul class="dropdown-menu">
#               <li>
#                   <a tabindex="-1" href="#">2 level</a>
#               </li>

#               <li class="dropdown-submenu">
#                   <a href="#">Header to 3rd Level</a>
#                   <ul class="dropdown-menu">
#                       <li><a href="#">3rd level</a></li>
#                       <li><a href="#">3rd level</a></li>
#                   </ul>
#               </li>

#               <li><a href="#">2nd level</a></li>
#               <li><a href="#">2nd level</a></li>
#           </ul>
#       </li>
#   </ul>
#</div>


#<div class="dropdown">
#   <a id="dLabel" role="button" data-toggle="dropdown" class="btn btn-primary" data-target="#" href="#">
#       Actions
#       <span class="caret"></span>
#   </a>
#   <ul class="dropdown-menu multi-level" role="menu" aria-labelledby="dropdownMenu">
#       <li><a href="#">First level</a></li>
#       <li><a href="#">First Level</a></li>
#       <li class="divider"></li>
#       <li class="dropdown-header">
#           <a href="#">First Level</a>
#       </li>
#       <li class="dropdown-header">
#           TEXT
#       </li>

#       <li class="dropdown-submenu">
#           <a tabindex="-1" href="#">Header for 2nd Level</a>

#           <ul class="dropdown-menu">
#               <li>
#                   <a tabindex="-1" href="#">2 level</a>
#               </li>

#               <li class="dropdown-submenu">
#                   <a href="#">Header to 3rd Level</a>
#                   <ul class="dropdown-menu">
#                       <li><a href="#">3rd level</a></li>
#                       <li><a href="#">3rd level</a></li>
#                   </ul>
#               </li>

#               <li><a href="#">2nd level</a></li>
#               <li><a href="#">2nd level</a></li>
#           </ul>
#       </li>
#   </ul>
#</div>

