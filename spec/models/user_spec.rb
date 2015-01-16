require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe User, '#update_roles' do

  it 'correctly adds a user role' do
    # setup
    user = User.create!({name: 'Test User', email: 'test@test.com', password: 'password'})
    expect(user.role_values).to eq []

    user.update_roles([UserRole::WRITER])
    expect(user.role_values).to eq [UserRole::WRITER]
  end

  it 'correctly removes a user role' do
    # setup
    user = User.create!({name: 'Test User', email: 'test@test.com', password: 'password'})
    writer_role = UserRole.create!({user_id: user.id, value: UserRole::WRITER})
    editor_role = UserRole.create!({user_id: user.id, value: UserRole::EDITOR})
    admin_role = UserRole.create!({user_id: user.id, value: UserRole::ADMIN})
    expect(UserRole.where(user_id: user.id)).to eq [writer_role, editor_role, admin_role]

    user.update_roles([UserRole::WRITER])
    expect(UserRole.where(user_id: user.id)).to eq [writer_role]
  end
end

describe User, '#role_values' do
  it 'correctly lists role values' do
    # setup
    user = User.create!({name: 'Test User', email: 'test@test.com', password: 'password'})
    writer_role = UserRole.create!({user_id: user.id, value: UserRole::WRITER})
    admin_role = UserRole.create!({user_id: user.id, value: UserRole::ADMIN})
    expect(user.role_values).to eq [UserRole::WRITER, UserRole::ADMIN]
  end
end
