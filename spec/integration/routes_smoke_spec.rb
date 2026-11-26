require 'rails_helper'

RSpec.describe "Routes Smoke Test", type: :request do
  it "toutes les routes GET publiques répondent avec 200 ou 201" do
    # Récupère les routes GET sans paramètres dynamiques (:id, :token, etc.) ni routes internes
    routes = Rails.application.routes.routes.select do |route|
      spec = route.path.spec.to_s
      route.verb == "GET" &&
        !spec.match?(/:(?!locale)/) && # Exclut tout paramètre dynamique autre que :locale
        !spec.start_with?("/rails", "/cable", "/assets", "/up")
    end

    routes.each do |route|
      path = route.path.spec.to_s
                  .gsub("(.:format)", "")
                  .gsub("(:locale)", "fr")
                  .gsub(":locale", "fr")

      get path

      expect([200, 201]).to include(response.status),
        "La route #{path} a retourné #{response.status} (redirection vers #{response.redirect_url || 'aucune'}) au lieu de 200/201"
    end
  end
end
