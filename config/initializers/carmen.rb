# config/initializers/carmen.rb
# Ruby 3.2+ compatibility patch for Carmen gem
unless File.respond_to?(:exists?)
  def File.exists?(path)
    exist?(path)
  end
end
