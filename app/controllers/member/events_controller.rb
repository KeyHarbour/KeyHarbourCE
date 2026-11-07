class Member::EventsController < Member::MemberController
  def index
    @events = Current.applications.events(params[:start], params[:end])
    @events = @events.map do |event|
      {
        id: event[:id],
        title: event[:title],
        start: event[:start],
        end: event[:end],
        allDay: true,
        color: event[:color],
        url: member_license_application_path(event[:item])
      }
    end

    render json: @events
  end
end
