class AddPdfPreviewToIssues < ActiveRecord::Migration
  def change
    add_attachment :issues, :pdf_preview
  end
end
