require 'will_paginate/view_helpers/link_renderer_base'

module WillPaginate
  module ViewHelpers
    # This class does the heavy lifting of actually building the pagination
    # links. It is used by +will_paginate+ helper internally.
    class LinkRenderer < LinkRendererBase

    protected
    
      def page_number(page)
        unless page == current_page
          link(page, page, :rel => rel_value(page), :class => "btn btn-default")
        else
          tag(:a, page, :class => 'current active btn btn-default')
        end
      end
      
      def gap
        text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
        %(<a class="gap btn btn-default disabled">#{text}</a>)
      end
      
      def previous_or_next_page(page, text, classname)
        if page
          link(text, page, :class => classname + ' btn btn-default')
        else
          tag(:a, text, :class => classname + ' disabled btn btn-default')
        end
      end
      
      def html_container(html)
        html
      end
      
    private

      def param_name
        @options[:param_name].to_s
      end

      def link(text, target, attributes = {})
        if target.is_a? Fixnum
          attributes[:rel] = rel_value(target)
          target = url(target)
        end
        attributes[:href] = target
        tag(:a, text, attributes)
      end

    end
  end
end
