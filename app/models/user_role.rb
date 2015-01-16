class UserRole < ActiveRecord::Base
  ADMIN = 1
  PUBLISHER = 2
  EDITOR_IN_CHIEF = 3
  PRODUCTION = 4
  NEWS_EDITOR = 5
  OPINION_EDITOR = 6
  CAMPUS_LIFE_EDITOR = 7
  ARTS_EDITOR = 8
  SPORTS_EDITOR = 9
  PHOTO_EDITOR = 10
  ONLINE_MEDIA_EDITOR = 11
  BUSINESS = 12
  STAFF = 13
  PRE_STAFF = 14

  ROLE_TITLES = {
    ADMIN => 'Administrator',
    PUBLISHER => 'Publisher',
    EDITOR_IN_CHIEF => 'Editor in chief',
    PRODUCTION => 'Production',
    NEWS_EDITOR => 'News editor',
    OPINION_EDITOR => 'Opinion editor',
    CAMPUS_LIFE_EDITOR => 'Campus Life editor',
    ARTS_EDITOR => 'Arts editor',
    SPORTS_EDITOR => 'Sports editor',
    PHOTO_EDITOR => 'Photo editor',
    ONLINE_MEDIA_EDITOR => 'Online media editor',
    BUSINESS => 'Business',
    STAFF => 'Staff',
    PRE_STAFF => 'New user'
  }

  # a list of all roles
  ROLES = ROLE_TITLES.keys
end
