module PaginationHelper
  # Renders a compact pagination: 1 2 ... >
  # - current_page: Integer (1-based)
  # - total_pages: Integer
  # - param: String for the page param name (e.g., 'products_page')
  def paginate_compact(current_page:, total_pages:, param:)
    return ''.html_safe if total_pages <= 1

    content_tag(:nav, class: 'pagination', role: 'navigation', aria: { label: 'Paginare' }) do
      parts = []

      # Page 1
      parts << page_link(1, current_page, param)
      # Page 2 (if exists)
      parts << page_link(2, current_page, param) if total_pages >= 2

      # Ellipsis if many pages beyond 2 and current_page > 2
      if total_pages > 3 && current_page > 2
        parts << content_tag(:span, '…', class: 'page-ellipsis')
      end

      # If current page is after 2 and before last, show it
      if current_page > 2 && current_page < total_pages
        parts << page_link(current_page, current_page, param)
      end

      # Next arrow
      if current_page < total_pages
        parts << page_link(current_page + 1, current_page, param, label: '›')
      end

      safe_join(parts)
    end
  end

  private

  def page_link(page, current_page, param, label: nil)
    label ||= page.to_s
    classes = ['page-link']
    classes << 'active' if page == current_page && label != '›'
    q = request.query_parameters.merge(param => page)
    link_to label, url_for(params.permit!.to_h.merge(q)), class: classes.join(' '), aria: { current: (page == current_page && label != '›' ? 'page' : nil) }
  end
end

