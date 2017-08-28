##
# app/beans/page_actions_builder.rb
#
# Build HTML for PageActions dropdown menus
#
########
# link_to macro takes three params(hashes), path, text, html_options_hash
# link_to(text, path, html_options_hash, &block)
#         p1,   p2,   p3
##
#  link_to(options = {}, html_options = {}) do
#     # name
#   end
#
#   link_to(url, html_options = {}) do
#     # name
#   end
#
# [{},{}]          #=> Two Items in dropdown
# [{},{},[{},{}]]  #=> Two items in dropdown, two in second level dropdown
#
# Params List
# [
#     { // Header Only
#         header: any_true_value,        # Exclusive: :id, :divider, & :text allowed
#         divider: any_true_value,       # optional
#         id: "test-action",             # optional
#         text: "I am a Header"          # optional
#     },
#     { // Divider Only
#         divider: true,                 # Required
#         id: "test-action"              # optional
#     },
#     { // Regular Dropdown Entry
#         id: "test-action",
#         path: :home_pages_path,
#         text: "Refresh",
#     },
#     { // Fully Dressed Entry
#         divider: any_true_value,       # appears after :li entry
#         path: :home_pages_path,
#         text: "Refresh",
#         icon: 'glyphicon-refresh',     # icons appear before text with seperating space
#         html_options: {                # applied to :link_to
#                id: "test-action",
#             class: 'something',
#             method: 'get',
#             data: {
#                 target: '#',
#                 package: []
#             }
#         }
#     },...
# ]

# Full Syntax
# [
#     {
#         header: any_true_value,        # Exclusive: :id, :divider, & :text allowed
#         divider: any_true_value,       # includes with :header, or others
#         id: "test-action",
#         path: :home_pages_path,        # see page_action_paths for full parm-list
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
# def do_page_actions(page_controls)
#   PageActionsBuilder.new(@page_controls..to_hash()[:page_actions], self, false).to_s
# end
# ####
# See doc at bottom of this file
##

class PageActionsBuilder

  attr_accessor :view, :bundle, :left_align
  
  # take what should be an Array, and the Controller or view instance
  def initialize(bundle, templater, left_align=false)
    @bundle = bundle
    @view = templater
    @left_align = left_align
  end

  delegate(:content_tag, :tag, :h, :link_to, to: :view)


  def to_s
    results = generate
    Rails.logger.debug "#{self.class.name}.#{__method__}() Results: #{results}"
    view.raw results
  end

  def prepare_options(params={})
    # fixup named routes
    params[:path] = @view.page_action_paths(params[:path]) if params.key?(:path)
    results = {
        html_options: params.delete(:html_options)
    }.merge(params)    # should|could include [:header, :divider, :id, :path, :text, :icon ])
    results.delete(:html_options) if results[:html_options].nil?
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
    html_options = (opts[:html_options].nil? ? {class: "btn btn-primary"} : opts[:html_options].merge(class: "btn #{opts[:html_options][:class]}") )
    content_tag(:div, class: (left_align ? "btn-group pull-left" : "btn-group pull-right"),  role: "group" ) do
      content_tag(:div, {class: 'dropdown', role: 'group'}) do
        link_to( opts[:path], html_options )  do
          stuffs = ""
          stuffs += (tag(:span,class: opts[:icon])  + "&nbsp;".html_safe) if opts.key?(:icon)
          stuffs += content_tag(:span, opts[:text])
          stuffs.html_safe
        end
      end
    end
  end


  def build_submenu(params=[])
    content_tag(:li, class: "dropdown-submenu", role: 'menu') do
      html = content_tag(:a, '#', {href: "#", class: "btn", role: "button", data: {toggle: 'dropdown', target: '#'}}) do
        text = (params.first.key?(:header) ? params.first[:header] : "More ")
        params.first.delete(:header) unless !text.eql?("More")
        content_tag(:span, text)
      end
      html += content_tag(:ul, {class: 'dropdown-menu', role: 'menu'}) do
        results = ""
        params.each do |item|
          item.is_a?(Array) ?
              results.concat( build_submenu(item) ) :
                results.concat( build_menu_item(item) )
        end
        results.html_safe
      end
      html.html_safe
    end.html_safe
  end

  def build_menu(params=[])
    content_tag(:div, class: (left_align ? "btn-group pull-left" : "btn-group pull-right"), role: "group" ) do
      content_tag(:div, {class: 'dropdown', role: 'group'}) do
        html = link_to("#", {id: 'dLabel', role: 'button',
                                     data: {toggle: 'dropdown', target: '#'},
                                     class: 'btn btn-primary'}) do
              stuffs = content_tag(:span, 'Actions ')
              stuffs += tag(:span, class: 'caret')
              stuffs.html_safe
        end
        html += content_tag(:ul, {class: 'dropdown-menu', role: 'menu'}) do
              results = ""
              params.each do |item|
                item.is_a?(Array) ?
                    results.concat( build_submenu(item) ) :
                      results.concat( build_menu_item(item) )
              end
              results.html_safe
        end
        html.html_safe
      end
    end.html_safe
  end

  def build_menu_item(params)
    html = ""
    opts = prepare_options(params)
    type = nil
    type = :li_header if opts.key?(:header) and opts[:html_options].nil?
    type = :li_divider if type.nil? and opts.key?(:divider) and opts[:html_options].nil?

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
            stuffs += (content_tag(:span, nil, class: opts[:icon] ) + "&nbsp;".html_safe) if opts.key?(:icon)
            stuffs += content_tag(:span, opts[:text])
            stuffs.html_safe
          end
        end
        html += tag(:li,class: "divider") if opts.key?(:divider)
        html
    end.html_safe
  end

end

###########################################################################
#  Generated by rspec test $ rpsec spec/views/page_action_builder_spec.rb
# #########################################################################
#
# No Dropdown, just one action button
#
#<div class="btn-group pull-left" role: "group">
#   <div class="dropdown" role="group">
#     <a data-samples="test data" class="btn btn-primary " href="/profiles/manage_content_profiles">
#       <span class="glyphicon glyphicon-refresh" />&nbsp;
#       <span>Refresh</span>
#     </a>
#   </div>
# </div>
#
#
# Single Level Dropdown (Single)
#
#<div class="btn-group pull-left" role: "group">
#   <div class="dropdown" role="group">
#     <a id="dLabel" role="button" data-toggle="dropdown" data-target="#" class="btn btn-primary" href="#">
#       <span>Actions</span>
#       <span class="caret" />
#     </a>
#     <ul class="dropdown-menu" role="menu">
#       <li>
#         <a data-samples="test data" href="/profiles/manage_content_profiles">
#           <span class="glyphicon glyphicon-refresh"></span>&nbsp;
#           <span>Refresh</span>
#         </a>
#       </li>
#       <li class="divider"></li>
#       <li class="dropdown-header">
#         <span>Header Test</span>
#       </li>
#       <li>
#         <a href="/profiles/manage_content_profiles">
#           <span>Refresh 2</span>
#         </a>
#       </li>
#       <li>
#         <a href="/profiles/manage_content_profiles">
#           <span>Refresh 3</span>
#         </a>
#       </li>
#       <li>
#         <a href="/profiles/manage_content_profiles">
#           <span>Refresh 4</span>
#         </a>
#       </li>
#     </ul>
#   </div>
# </div>
#

#
# Multi-Level Dropdown (Nested)
#
# <div class="pull-right">
#   <div class="dropdown" role="group">
#     <a id="dLabel" role="button" data-toggle="dropdown" data-target="#" class="btn btn-primary" href="#">
#       <span>Actions</span>
#       <span class="caret" />
#     </a>
#     <ul class="dropdown-menu" role="menu">
#       <li class="dropdown-header"><span>I am a Header</span></li>
#       <li class="divider"></li>
#       <li><a href="/profiles/manage_content_profiles"><span>Refresh</span></a></li>
#       <li><a class="something" data-target="#" data-package="[&quot;someData&quot;]" data-method="get" href="/profiles/manage_content_profiles"><span class="glyphicon glyphicon-refresh"></span>&nbsp;<span>Refresh</span></a></li>
#       <li class="divider" />
#       <li class="dropdown-submenu" role="menu">
#         <a href="#" class="btn" role="button" data-toggle="dropdown" data-target="#">
#           <span>Rspec Testing</span>
#         </a>
#         <ul class="dropdown-menu" role="menu">
#           <li><a data-samples="test data" href="/profiles/manage_content_profiles"><span class="glyphicon glyphicon-refresh"></span>&nbsp;<span>Refresh</span></a></li>
#         </ul>
#       </li>
#     </ul>
#   </div>
# </div>
