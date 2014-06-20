class AddLetterToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :letter, :string
  end
end
