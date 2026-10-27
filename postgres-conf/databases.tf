resource "postgresql_role" "test" {
  name                      = "test"
  password                  = "test"
  login                     = true
  encrypted_password        = true
  superuser                 = false
  create_database           = false
  create_role               = false
  replication               = false
  bypass_row_level_security = false 
}

resource "postgresql_database" "test" {
  name              = "test"
  owner             = postgresql_role.test.name
  connection_limit  = 100
  allow_connections = true
  tablespace_name   = "pg_default"
  is_template       = false
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "en_US.utf8"
  lc_ctype          = "en_US.utf8"
}


resource "postgresql_role" "keycloak" {
  name                      = "keycloak"
  password                  = "keycloak"
  login                     = true
  encrypted_password        = true
  superuser                 = false
  create_database           = false
  create_role               = false
  replication               = false
  bypass_row_level_security = false 
}

resource "postgresql_database" "keycloak" {
  name              = "keycloak"
  owner             = postgresql_role.keycloak.name
  connection_limit  = 100
  allow_connections = true
  tablespace_name   = "pg_default"
  is_template       = false
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "en_US.utf8"
  lc_ctype          = "en_US.utf8"
}

resource "postgresql_role" "ranger" {
  name                      = "ranger"
  password                  = "ranger"
  login                     = true
  encrypted_password        = true
  superuser                 = false
  create_database           = false
  create_role               = false
  replication               = false
  bypass_row_level_security = false 
}

resource "postgresql_database" "ranger" {
  name              = "ranger"
  owner             = postgresql_role.ranger.name
  connection_limit  = 100
  allow_connections = true
  tablespace_name   = "pg_default"
  is_template       = false
  template          = "template0"
  encoding          = "UTF8"
  lc_collate        = "en_US.utf8"
  lc_ctype          = "en_US.utf8"
}