UsuarioAdministrador.create(
  nome: "Administrador",
  username: "admin",
  email: "admin@devconnit.com",
  password: "qwe123@#",
  password_confirmation: "qwe123@#",
  active: true
)


# entidade1 = Entidade.new(
#   active: true,
#   nome: "Entidade 001",
#   numero_limite_usuarios: 12,
#   situacao: 1,
#   slug: "entidade001"
# )

# entidade1.save!

# entidade2 = Entidade.create(
#   active: true,
#   nome: "Entidade 002",
#   numero_limite_usuarios: 12,
#   situacao: 1,
#   slug: "entidade002"
# )

# UsuarioEntidade.create(
#   active: true,
#   eh_administrador: true,
#   email: "entidade001@devconnit.com",
#   entidade_id: entidade1.id,
#   nome: "Administrador Entidade 001",
#   username: "admin.entidade001",
#   password: "qwe123@#",
#   password_confirmation: "qwe123@#"
# )

# UsuarioEntidade.create(
#   active: true,
#   eh_administrador: true,
#   email: "entidade002@devconnit.com",
#   entidade_id: entidade2.id,
#   nome: "Administrador Entidade 002",
#   username: "admin.entidade002",
#   password: "qwe123@#",
#   password_confirmation: "qwe123@#"
# )

# Unidade.create(
#   active: true,
#   entidade_id: entidade1.id,
#   nome: "Unidade 001.1",
#   situacao: 1,
#   slug: "unidade001-1"
# )
# Unidade.create(
#   active: true,
#   entidade_id: entidade1.id,
#   nome: "Unidade 001.2",
#   situacao: 1,
#   slug: "unidade001-2"
# )

# Unidade.create(
#   active: true,
#   entidade_id: entidade2.id,
#   nome: "Unidade 002.1",
#   situacao: 1,
#   slug: "unidade002-1"
# )

# Unidade.create(
#   active: true,
#   entidade_id: entidade2.id,
#   nome: "Unidade 002.2",
#   situacao: 1,
#   slug: "unidade002-2"
# )
