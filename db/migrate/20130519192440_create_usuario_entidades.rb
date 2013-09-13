class CreateUsuarioEntidades < ActiveRecord::Migration
  def change
    create_table :usuario_entidades do |t|
      t.string :nome
      t.string :email
      t.string :username
      t.integer :entidade_id
      t.boolean :eh_administrador
      t.string :password_digest
      t.string :autentication_token
      t.boolean :active

      t.timestamps
    end
  end
end
