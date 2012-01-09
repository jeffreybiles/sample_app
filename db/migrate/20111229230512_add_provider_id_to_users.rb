class AddProviderIdToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider_id, :integer, :default => nil
  end
end
