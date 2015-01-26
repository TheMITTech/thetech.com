require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe User, '#update_roles' do
  it 'correctly adds a user role' do
    # setup
    user = create(:user)
    expect(user.role_values).to eq []

    user.update_roles([UserRole::PUBLISHER])
    expect(user.role_values).to eq [UserRole::PUBLISHER]
  end

  it 'correctly removes a user role' do
    # setup
    user = create(:user)
    publisher_role = create(:publisher_role, user_id: user.id)
    editor_in_chief_role = create(:editor_in_chief_role, user_id: user.id)
    admin_role = create(:admin_role, user_id: user.id)
    expect(UserRole.where(user_id: user.id)).to eq [publisher_role, editor_in_chief_role, admin_role]

    user.update_roles([UserRole::PUBLISHER])
    expect(UserRole.where(user_id: user.id)).to eq [publisher_role]
  end
end

describe User, '#role_values' do
  it 'correctly lists role values' do
    # setup
    user = create(:user)
    admin_role = create(:admin_role, user_id: user.id)
    editor_in_chief_role = create(:editor_in_chief_role, user_id: user.id)
    expect(user.role_values).to eq [UserRole::ADMIN, UserRole::EDITOR_IN_CHIEF]
  end
end
