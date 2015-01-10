namespace :css do
  task generate_contents_css: :environment do
    scss_file = File.join(Rails.root, 'app/assets/stylesheets/piece_display.css.scss')
    css_file = File.join(Rails.root, 'public/contents.css')

    `sass "#{scss_file}" "#{css_file}"`
  end
end
