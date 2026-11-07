# frozen_string_literal: true

module PagyBootstrapHelper
  def pagy_bootstrap_nav(pagy)
    html = +%(<nav aria-label="Pagination"><ul class="pagination">)

    # Prev
    if pagy.prev
      html << %(<li class="page-item"><a class="page-link" href="#{pagy_url_for(pagy.prev)}">&laquo;</a></li>)
    else
      html << %(<li class="page-item disabled"><span class="page-link">&laquo;</span></li>)
    end

    # Pages
    pagy.series.each do |item|
      if item.is_a?(Integer)
        html << %(<li class="page-item#{' active' if item == pagy.page}"><a class="page-link" href="#{pagy_url_for(item)}">#{item}</a></li>)
      elsif item == :gap
        html << %(<li class="page-item disabled"><span class="page-link">&hellip;</span></li>)
      end
    end

    # Next
    if pagy.next
      html << %(<li class="page-item"><a class="page-link" href="#{pagy_url_for(pagy.next)}">&raquo;</a></li>)
    else
      html << %(<li class="page-item disabled"><span class="page-link">&raquo;</span></li>)
    end

    html << %(</ul></nav>)
    html.html_safe
  end
end