class CreateComments < ActiveRecord::Migration[5.2]
  def change
    create_table :comments do |t|
      t.text :content
      t.references :subject, polymorphic: true
      t.references :admin, foreign_key: true

      t.timestamps
    end
  end
end
