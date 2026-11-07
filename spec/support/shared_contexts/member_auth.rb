RSpec.shared_context "member_auth" do
  let(:owner_role) { Role.find_or_create_by!(name: "Owner") }

  let(:account) do
    Account.unscoped.create!(
      name: "Test Account",
      country_code: "CA",
      province_code: "QC",
      billing_contact: "billing@test.com"
    )
  end

  let(:user) { create(:user) }

  let(:account_user) do
    AccountUser.unscoped.create!(user: user, account: account, role: owner_role)
  end

  let(:session_record) { Session.create!(user: user) }

  before do
    account_user # force creation so user.account_user is real
    Current.session = session_record
    cookies.signed[:session_id] = session_record.id

    allow(Current).to receive(:billing_range).and_return(DateTime.now.advance(months: -1)..DateTime.now)
    allow(Current).to receive(:subscription).and_return(account.subscription)
    allow(Rails.configuration).to receive(:permission_service).and_return(double("ps", get: false))
    allow_any_instance_of(ApplicationController).to receive(:enforce_custom_permissions!).and_return(true)
    allow(controller).to receive(:validate_account).and_return(true)
    allow(controller).to receive(:check_role).and_return(true)
  end
end
