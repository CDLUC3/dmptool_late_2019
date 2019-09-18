class AddDoiToPlans < ActiveRecord::Migration
  def change
    add_column :plans, :doi, :string, index: true, null: true
  end
end
