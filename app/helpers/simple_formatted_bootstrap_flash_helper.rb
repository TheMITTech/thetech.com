module SimpleFormattedBootstrapFlashHelper
  ALERT_TYPES = [:success, :info, :warning, :danger] unless const_defined?(:ALERT_TYPES)

  def simple_formatted_bootstrap_flash(options = {})
    flash_messages = []

    collected_flash = {}

    @flash.each do |type, message|
      collected_flash[type] ||= []
      collected_flash[type] << message
    end

    flash.each do |type, message|
      collected_flash[type] ||= []
      collected_flash[type] << message
    end

    collected_flash.each do |type, messages|
      messages.each do |message|
        # Skip empty messages, e.g. for devise messages set to nothing in a locale file.
        next if message.blank?

        type = type.to_sym
        type = :success if type == :notice
        type = :danger  if type == :alert
        type = :danger  if type == :error
        next unless ALERT_TYPES.include?(type)

        Array(message).each do |msg|
          text = content_tag(:div,
                             content_tag(:button, raw("&times;"), :class => "close", "data-dismiss" => "alert") +
                             msg.gsub("\n", "<br>").html_safe, :class => "alert fade in alert-#{type} #{options[:class]}")
          flash_messages << text if msg
        end
      end
    end

    flash_messages.join("\n").html_safe
  end
end
