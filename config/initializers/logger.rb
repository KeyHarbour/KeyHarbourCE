if Rails.env.development?
  CUSTOM_LOGGER = ActiveSupport::Logger.new(Rails.root.join("log", "controller_and_views.log"))

  class SimpleControllerLogger < ActiveSupport::LogSubscriber
    def process_action(event)
      payload = event.payload
      status = payload[:status]

      if status.nil? && payload[:exception].present?
        status = ActionDispatch::ExceptionWrapper.status_code_for_exception(payload[:exception].first)
      end

      # Écrit uniquement dans le fichier personnalisé
      CUSTOM_LOGGER.info "[Controller] #{payload[:controller]}##{payload[:action]}"
      CUSTOM_LOGGER.info "[Status]: #{status}\n\n"
    end
  end
  SimpleControllerLogger.attach_to :action_controller

  # 3. Log des vues et des partiels
  class SimpleViewLogger < ActiveSupport::LogSubscriber
    def render_template(event)
      path = event.payload[:identifier].sub("#{Rails.root}/", "")
      CUSTOM_LOGGER.info "[View] #{path}"
    end

    def render_partial(event)
      path = event.payload[:identifier].sub("#{Rails.root}/", "")
      CUSTOM_LOGGER.info "[Partial] #{path}"
    end
  end
  SimpleViewLogger.attach_to :action_view
end
