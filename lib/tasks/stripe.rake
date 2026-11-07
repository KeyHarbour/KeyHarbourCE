namespace :stripe do
  desc "Sync product catalogue"
  task sync_product: :environment do
    Plan.all.each do |plan|
      puts "Syncing #{plan.name} with Stripe..."
      plan.sync_with_stripe
    end
  end
end
