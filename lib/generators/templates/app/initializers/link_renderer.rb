require 'will_paginate/view_helpers/action_view'

module WillPaginate
  module ActionView
    class BootstrapLinkRenderer < LinkRenderer

      protected

      def page_number(page)
        is_current_page = (page == current_page)
        temphtml = '<li class="page-item ' + (is_current_page ? 'active' : '') + '">'
        unless is_current_page
          temphtml += link(page, page, :rel => rel_value(page), :class => 'page-link')
        else
          temphtml += tag(:a, page, :class => 'current active page-link')
        end
        temphtml += '</li>'
        temphtml
      end

      def gap
        text = @template.will_paginate_translate(:page_gap) { '&hellip;' }
        %(<a class="gap btn btn-default disabled">#{text}</a>)
      end

      def previous_or_next_page(page, text, classname)
        temphtml = '<li class="page-item">'
        if page
          temphtml += link(text, page, :class => classname + ' page-link')
        else
          temphtml += tag(:a, text, :class => classname + ' page-link')
        end
        temphtml += '</li>'
        temphtml
      end

      def html_container(html)
        '<ul class="pagination pagination-sm justify-content-end mb-0">' + html + '</ul>'
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
