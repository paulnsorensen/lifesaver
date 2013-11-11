require 'spec_helper' 

describe Lifesaver::Notification::TraversalQueue do
  let(:traversal_queue) { Lifesaver::Notification::TraversalQueue.new }
  let(:model) { Model.new(1) }

  describe "#push" do
    it "adds an univisited model" do
      traversal_queue.push(model)
      expect(traversal_queue.size).to eql(1)
    end

    it "ignores a visited model" do
      traversal_queue.push(model)
      traversal_queue.push(model)
      expect(traversal_queue.size).to eql(1)
    end
  end

  describe "#<<" do
    it "adds an univisited model" do
      traversal_queue << model
      expect(traversal_queue.size).to eql(1)
    end

    it "ignores a visited model" do
      traversal_queue << model
      traversal_queue << model
      expect(traversal_queue.size).to eql(1)    
    end
  end

  describe "#pop" do
    context "when not empty" do
      it "returns the first model in the queue" do
        another_model = Model.new(3)
        traversal_queue << model
        traversal_queue << another_model
        expect(traversal_queue.pop).to eql(model)
      end
    end

    context "when empty" do
      it "returns nil" do
        expect(traversal_queue.pop).to be_nil
      end
    end
  end

  describe "#empty?" do
    it "is true when empty" do
      expect(traversal_queue.empty?).to be_true
    end

    it "is not true when not empty" do
      traversal_queue << model
      expect(traversal_queue.empty?).to be_false
    end
  end

end
