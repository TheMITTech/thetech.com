class UserRole < AbstractModel
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
    ADMIN => 'Administrator',
    PUBLISHER => 'Publisher',
    EDITOR_IN_CHIEF => 'Editor in Chief',
    PRODUCTION => 'Production Staff',
    NEWS_EDITOR => 'News Editor',
    OPINION_EDITOR => 'Opinion Editor',
    CAMPUS_LIFE_EDITOR => 'Campus Life Editor',
    ARTS_EDITOR => 'Arts Editor',
    SPORTS_EDITOR => 'Sports Editor',
    PHOTO_EDITOR => 'Photo Editor',
    ONLINE_MEDIA_EDITOR => 'Online Media Editor',
    BUSINESS => 'Business Staff',
    STAFF => 'Staff'
  }

  # a list of all roles
  ROLES = ROLE_TITLES.keys
end
