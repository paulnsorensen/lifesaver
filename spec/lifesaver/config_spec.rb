require 'spec_helper'

describe Lifesaver::Config do
  describe "#initialize" do
    context "with no options" do
      let(:config) { Lifesaver::Config::new } 

      it "has the default indexing_queue" do
        expect(config.indexing_queue).to eql(:lifesaver_indexing)
      end

      it "has the default notification_queue" do
        expect(config.notification_queue).to eql(:lifesaver_notification)
      end
    end
  end
end