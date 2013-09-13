class CreateUsuarioAdministradores < ActiveRecord::Migration
  def change
    create_table :usuario_administradores do |t|
      t.string :nome
      t.string :email
      t.string :password_digest
      t.string :username
      t.string :autentication_token
      t.boolean :active

      t.timestamps
    end
  end
end
