require 'lims-core/persistence/message_bus'

module Lims::Core
  module Persistence
    describe MessageBus, :message_bus => true do
      context "to be valid" do
        let(:url) { "amqp://user:password@localhost:55672" }
        let(:exchange_name) { "exchange_name" }
        let(:durable) { true }
        let(:prefetch_number) { 30 }
        let(:heart_beat) { 0 }
        let(:backend_application_id) { "test backend app" }
        let(:another_backend_application_id) { "another backend app id" }
        let(:bus_settings) { {  "url"                     => url,
                                "exchange_name"           => exchange_name,
                                "durable"                 => durable,
                                "prefetch_number"         => prefetch_number,
                                "heart_beat"              => heart_beat,
                                "backend_application_id"  => backend_application_id}
        }

        it "requires a RabbitMQ host" do
          described_class.new(bus_settings - ["url"]).valid?.should == false
        end

        it "requires an exchange name" do
          described_class.new(bus_settings - ["exchange_name"]).valid?.should == false
        end

        it "requires the durable option" do
          described_class.new(bus_settings - ["durable"]).valid?.should == false
        end

        it "requires a prefetch number" do
          described_class.new(bus_settings - ["prefetch_number"]).valid?.should == false
        end

        it "not requires a heart_beat value" do
          described_class.new(bus_settings - ["heart_beat"]).valid?.should == true
        end

        it "requires the backend_application_id value" do
          described_class.new(bus_settings - ["backend_application_id"]).valid?.should == false
        end

        it "requires correct settings" do
          described_class.new(bus_settings).valid?.should == true
        end
  
        it "sets the exchange type to topic by default" do
          described_class.new(bus_settings).exchange_type.should == "topic"
        end

        it "requires correct settings to connect to the message bus" do
          expect do
            described_class.new(bus_settings - ["url"]).connect
          end.to raise_error(MessageBus::InvalidSettingsError)
        end

        it "requires an exchange to publish a message" do
          expect do
            described_class.new(bus_settings).publish("message")
          end.to raise_error(MessageBus::ConnectionError)
        end

        it "raise an error if set the backend app id more then once" do
          expect do
            message_bus = described_class.new(bus_settings)
            message_bus.backend_application_id = another_backend_application_id
          end.to raise_error(MessageBus::InvalidSettingsError)
        end
      end
    end
  end 
end

