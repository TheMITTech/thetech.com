class UserRole < ActiveRecord::Base  
  WRITER = 1
  EDITOR = 2
  ADMIN  = 3

  ROLE_TITLES = {
    WRITER  => 'Writer',
    EDITOR  => 'Editor',
    ADMIN   => 'Full Access'
  }

  # a list of all roles
  ROLES = ROLE_TITLES.keys
end
