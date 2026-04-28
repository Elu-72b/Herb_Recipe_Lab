class AddUserToHerbs < ActiveRecord::Migration[7.2]
  def change
    add_reference :herbs, :user, null: true, foreign_key: true
  end
end
