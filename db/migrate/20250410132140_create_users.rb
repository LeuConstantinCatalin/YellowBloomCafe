class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users do |t|
      t.string :username
      t.string :nume
      t.string :prenume
      t.date :data_nastere
      t.string :email
      t.string :password_digest
      t.string :tip
      t.string :adresa

      t.timestamps
    end
  end
end
