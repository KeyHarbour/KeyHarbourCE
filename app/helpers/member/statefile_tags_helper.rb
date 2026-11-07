module Member::StatefileTagsHelper
  def new_item_url
    new_member_statefile_statefile_tag_path(@statefile)
  end

  def form_url
    return member_statefile_statefile_tags_path(@statefile) if @item.new_record?
    member_statefile_tag_path(@item)
  end

  def index_page_name
    t('member.statefile_tags.index.title')
  end

  def search
    false
  end
end
