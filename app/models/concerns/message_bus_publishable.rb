module MessageBusPublishable
  extend ActiveSupport::Concern

  included do
    after_save :publish_message_bus_update
    after_touch :publish_message_bus_update
  end

  private
    def publish_message_bus_update
      MessageBus.publish '/updates', {model: self.class.name.underscore, id: self.id}
    end
end