# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = "1.0"
Rails.application.config.assets.precompile += %w(
  application.css
  styles.css
  employee_controls.css
  employee_sidebar.css
  gallery.css
  home.css
  about.css
  account.css
  menu.css
  order_sidebar.css
)


# Add additional assets to the asset load path.
# Rails.application.config.assets.paths << Emoji.images_path
