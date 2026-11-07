class AddServiceNameToApiQueries < ActiveRecord::Migration[8.1]
  def change
    add_column :api_queries, :service_name, :string
    add_index :api_queries, :service_name
    add_index :api_queries, :date
  end
end
