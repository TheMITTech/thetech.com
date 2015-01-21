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

  ROLE_TITLES = {
    ADMIN => 'Administrators',
    PUBLISHER => 'Publishers',
    EDITOR_IN_CHIEF => 'Editor in chief',
    PRODUCTION => 'Production',
    NEWS_EDITOR => 'News editors',
    OPINION_EDITOR => 'Opinion editors',
    CAMPUS_LIFE_EDITOR => 'Campus Life editors',
    ARTS_EDITOR => 'Arts editors',
    SPORTS_EDITOR => 'Sports editors',
    PHOTO_EDITOR => 'Photo editors',
    ONLINE_MEDIA_EDITOR => 'Online media editors',
    BUSINESS => 'Business',
    STAFF => 'Staff'
  }

  # a list of all roles
  ROLES = ROLE_TITLES.keys
end
