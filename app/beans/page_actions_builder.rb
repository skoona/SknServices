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
# Parm List
# [
#     { // Header Only
#         header: any_true_value,                    # Exclusive: :id, :divider, & :text allowed
#         divider: any_true_value,                   # optional
#         id: "test-action",                         # optional
#         text: "I am a Header"                      # optional
#     },
#     { // Divider Only
#         divider: true,                             # Required
#         id: "test-action"                          # optional
#     },
#     { // Regular Dropdown Entry
#         id: "test-action",
#         path: :home_pages_path,
#         text: "Refresh",
#     },
#     { // Fully Dressed Entry
#         divider: any_true_value,
#         id: "test-action",
#         path: :home_pages_path,
#         text: "Refresh",
#         icon: 'glyphicon-refresh',
#         html_options: {
#             class: 'something',
#             method: 'get',
#             data: {
#                 target: '#',
#                 package: []
#             }
#         }
#     },...

# Full Syntax
# [
#     {
#         header: any_true_value,                    # Exclusive: :id, :divider, & :text allowed
#         divider: any_true_value,                   # includes with :header, or others
#         id: "test-action",
#         path: :home_pages_path,                    # see page_action_paths for full parm-list
#         text: "Refresh",
#         icon: 'glyphicon-refresh',
#         html_options: {
#             class: 'something',
#             method: 'get',
#             data: {
#                 target: '#',
#                 package: []
#             }
#         }
#     },...
# ]

## usage
# page_actions = []
# page_actions << {
# }
########
#
##

class PageActionsBuilder

  attr_accessor :view, :bundle, :left_align
  
  # take what should be an Array, and the Controller or view instance
  def initialize(bundle, templater, left_align=false)
    @bundle = bundle
    @view = templater
    @left_align = left_align
  end

  delegate(:content_tag, :tag, :action_name, :h, :link_to, to: :view)


  def to_s
    results = generate
    Rails.logger.debug "#{self.class.name}.#{__method__}() Results: #{results}"
    view.raw results
  end

  def prepare_options(params={})
    # fixup named routes
    params[:path] = page_action_paths(params[:path]) if params[:path]
    results = {
        html_options: params.delete(:html_options)
    }.merge(params)    # should|could include [:header, :divider, :id, :path, :text, :icon ])
    Rails.logger.debug "#{self.class.name}.#{__method__}() Results: #{results}"
    results
  end


  def generate
    view.raw( @bundle.length != 1 ? build_menu(@bundle) : build_single(@bundle) )
  end


  #   <div class="dropdown" role="group">
  #       <a id="dLabel" role="button" class="btn btn-primary" href="/pages/home">
  #           <span class="glyphicon glyphicon-home"></span>
  #           <span>Actions</span>
  #           <span class="glyphicon glyphicon-cog"></span>
  #       </a>
  #   </div>
  def build_single(params=[])
    opts = prepare_options(params.first)
    content_tag(:div, class: left_align ? "pull-left" : "pull-right" ) do
      content_tag(:div, {class: 'dropdown', role: 'group'}) do
        link_to(opts[:path], opts[:html_options] ) do
          stuffs = ""
          stuffs += tag(:span,class:"glyphicon #{opts[:icon]}" ) if opts.key?(:icon)
          stuffs += content_tag(:span, opts[:text])
          stuffs.html_safe
        end
      end
    end
  end


  def build_submenu(params=[])
    ""
    # frame sub-menu, then loop to items
  end

  def build_menu(params=[])
    content_tag(:div, class: left_align ? "pull-left" : "pull-right" ) do
      content_tag(:div, {class: 'dropdown', role: 'group'}) do
        html = link_to("#", {id: 'dLabel', role: 'button',
                                     data: {toggle: 'dropdown', target: '#'},
                                     class: 'btn btn-primary'}) do
              stuffs = content_tag(:span, 'Actions')
              stuffs += tag(:span, class: 'caret')
              stuffs
        end
        html += content_tag(:ul, {class: 'dropdown-menu multi-level', role: 'menu'}) do
              results = ""
              params.each do |item|
                item.is_a?(Array) ?
                    results.concat( build_sub_menu(item) ) :
                      results.concat( build_menu_item(item) )
              end
              results
        end
        html
      end
    end.html_safe
  end

  def build_menu_item(params)
    html = ""
    opts = prepare_options(params)
    type = nil
    type = :li_header if opts.key?(:header)
    type = :li_divider if type.nil? and opts.key?(:divider) and opts[:html_options].nil?

    puts "HELPS BUILD ITEM ============= #{opts}"

    case type
      when :li_header
        content_tag(:li, class: 'dropdown-header') do
          content_tag(:span, opts[:text], opts[:html_options])
        end
      when :li_divider
        content_tag(:li,nil, class: "divider")
      else
        html = content_tag(:li ) do
          link_to(opts[:path], opts[:html_options] ) do
            stuffs = ""
            stuffs += tag(:span,class:"glyphicon #{opts[:icon]}" ) if opts.key?(:icon)
            stuffs += content_tag(:span, opts[:text])
            stuffs.html_safe
          end
        end
        html += tag(:li,class: "divider") if opts.key?(:divider)
        html
    end.html_safe

  end

  ### Converts named routes to string
  #  Basic '/some/hardcoded/string/path'
  #        '[:named_route_path]'
  #        '[:named_route_path, {options}]'
  #        '[:named_route_path, {options}, '?query_string']'
  #
  # Advanced ==> {engine: :demo, path: :demo_profiles_path, options: {id: 111304}, query: '?query_string'}
  #              {engine: , path: , options: {}, query: ''}
  def page_action_paths(paths)
    case paths
      when Array
        case paths.size
          when 1
            view.send( paths[0] )
          when 2
            view.send( paths[0], paths[1] )
          when 3
            rstr = view.send( paths[0], paths[1] )
            rstr + paths[2]
        end

      when Hash
        rstr = view.send(paths[:engine]).send(paths[:path], paths.fetch(:options,{}) )
        rstr + paths.fetch(:query, '')

      when String
        paths
    end
  rescue
    '#page_action_error'
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

