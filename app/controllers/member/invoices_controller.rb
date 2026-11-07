
class Member::InvoicesController < Member::MemberController
  def datum
    Current.subscription.invoices
  end

  def show
    # render layout: 'pdf'
    respond_to do |format|
      format.html
      format.pdf do
        html = render_to_string(layout: 'pdf', action: 'show', formats: [ :html ])
        css_path = Rails.root.join("app/assets/builds/application.css")
        absolute_css_path = css_path.to_s.strip
        css_content = File.read(absolute_css_path)

        html_string = "<style>#{css_content}</style>" + render_to_string(action: 'show', layout: 'pdf', formats: [ :html ])

        render ferrum_pdf: {
          html: html_string,
          landscape: false,
          scale: 1,
          print_background: true
        },
        layout: 'pdf',
        disposition: 'attachment',
        filename: "#{@item.ref}.pdf"
      end
    end
  end

  private
  
  def set_item
    @item = datum.find_by(id: params[:id])
  end
end