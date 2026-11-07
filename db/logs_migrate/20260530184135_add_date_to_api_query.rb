class AddDateToApiQuery < ActiveRecord::Migration[8.1]
  disable_ddl_transaction!  

  def change
    add_column :api_queries, :date, :datetime, default: -> { "CURRENT_TIMESTAMP" }, null: false
    # ApiQuery.all.each do |api_query|
    #   api_query.update(date: api_query.created_at)
    # end
  end
end
