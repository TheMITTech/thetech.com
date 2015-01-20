require_relative '../rails_helper'

# Prefix instance methods with a '#'
describe User, '#update_roles' do

  it 'correctly adds a user role' do
    # setup
    user = create(:user)
    expect(user.role_values).to eq []

    user.update_roles([UserRole::WRITER])
    expect(user.role_values).to eq [UserRole::WRITER]
  end

  it 'correctly removes a user role' do
    # setup
    user = create(:user)
    writer_role = create(:writer_role, user_id: user.id)
    editor_role = create(:editor_role, user_id: user.id)
    admin_role = create(:admin_role, user_id: user.id)
    expect(UserRole.where(user_id: user.id)).to eq [writer_role, editor_role, admin_role]

    user.update_roles([UserRole::WRITER])
    expect(UserRole.where(user_id: user.id)).to eq [writer_role]
  end
end

describe User, '#role_values' do
  it 'correctly lists role values' do
    # setup
    user = create(:user)
    writer_role = create(:writer_role, user_id: user.id)
    admin_role = create(:admin_role, user_id: user.id)
    expect(user.role_values).to eq [UserRole::WRITER, UserRole::ADMIN]
  end
end
