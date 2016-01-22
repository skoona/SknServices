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

    return @service.raw(build_single(@bundle)) if bundle.one?

    html = @bundle.each_with_object('') do |item, results|
      case item
        when Hash
          results.concat( build_single(item) )
        when Array
          results.concat( build_menu(item) )
        else
          ""
      end
    end
    # prepare_options
    #   call build_single
    #   call build_menu (if item == Array call build_submenu)
    #   call build_submenu (if item == Array call build_submenu/re-entrant)
    @service.raw( html.join() )
  end
  def prepare_options(params={})
    # fixup named routes
    params[:path] = page_action_paths(params[:path]) if params[:path]
    {
        html_options: params.delete(:html_options),
        control:  params   # should|could include [:header, :divider, :id, :path, :text, :icon ]
    }
  end

  def build_single(params=[])
    opts = prepare_options(item)
    build_menu_html(opts)
  end
  def build_menu(params=[])
  end
  def build_submenu(params=[])
  end

  def build_menu_html(params)
    opts = prepare_options(params)
    type = nil
    type = :li_header if opts[:control][:header]
    type = :li_divider if type.nil? or opts[:control][:li_divider]

    case type
      when :li_header
        opts[:html_options][:class] = opts[:html_options][:class] + " dropdown-header"
        content_tag(:li, content_tag(:span, opts[:control][:text]), opts[:html_options])
        #
      when :li_divider
        opts[:html_options][:class] = opts[:html_options][:class] + " divider"
        content_tag(:li,nil,opts[:html_options])
        #
      else
        content_tag(:li, content_tag(:span, text, html_options))
        #
    end
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

