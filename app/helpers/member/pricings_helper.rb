module Member::PricingsHelper
  def breadcrumbs
    result = super
    result += breadcrumbs_restfull( :"member/pricings", member_pricings_path, @item&.name, @item&.id )
    result
  end


  def table_td(index, max)
    if index == 0
      "border-s border-b bg-muted/40 px-5! py-3.5!"
    elsif index == max - 1
      "border-b border-s border-e px-5! py-3.5!"
    else
      "border-b border-s px-5! py-3.5!"
    end
  end
end
