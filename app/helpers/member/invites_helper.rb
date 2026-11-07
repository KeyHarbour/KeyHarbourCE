module Member::InvitesHelper
  def new_item_url
    new_member_organization_invite_path(@organization)
  end

  def form_url
    return member_organization_invites_path(@organization, locale: I18n.locale) if @item.new_record?
    member_organization_invite_path(@organization, @item, locale: I18n.locale)
  end

  def index_page_name
    t('member.invites.index.page_title')
  end
end
