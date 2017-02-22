class RenameLegacyCommentsToPreRebirthLegacyComments < ActiveRecord::Migration
  def change
    rename_table :legacy_comments, :pre_rebirth_legacy_comments
  end
end
