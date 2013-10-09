require 'spec_helper'

describe Lifesaver::Marshal do
  describe ".is_serialized?" do
    it "returns true if Hash has :id and :class" do
      obj = { class: :post, id: 1 }
      expect(Lifesaver::Marshal.is_serialized?(obj)).to eql(true)
    end

    it "returns true if Hash has 'id' and 'class'" do
      obj = { "class" => "post", "id" => "1" }
      expect(Lifesaver::Marshal.is_serialized?(obj)).to eql(true)
    end

    it "returns false if Hash does not have id and class keys" do
      obj = { some_key: 1, id: 4 }
      expect(Lifesaver::Marshal.is_serialized?(obj)).to eql(false)
    end

    it "returns false if passed an non-Hash object" do
      obj = Post.new
      expect(Lifesaver::Marshal.is_serialized?(obj)).to eql(false)
    end
  end

  describe ".sanitize" do
    it "returns symbolized version of the Hash'" do
      obj = { "class" => "post", "id" => "1", "status" => "updated" }
      out = { class: :post, id: 1, status: :updated }
      expect(Lifesaver::Marshal.sanitize(obj)).to eql(out)
    end

    it "rejects non-Hashes" do
      obj = Post.new
      expect { Lifesaver::Marshal.sanitize(obj) }.to raise_error
    end
  end

  describe ".load" do
    before(:all) do
      Post.create(title: "Test Post")
    end

    it "loads a serialized object from ActiveRecord" do
      obj = { class: :post, id: 1 }
      expect(Lifesaver::Marshal.load(obj)).to eql([Post.find(1), {}])
    end

    it "returns nil if model not found" do
      obj = { class: :post, id: 12 }
      expect(Lifesaver::Marshal.load(obj)).to eql(nil)
    end

    it "returns options if they were passed" do
      obj = { class: :post, id: 1, status: :notified }
      m = Lifesaver::Marshal.load(obj)
      expect(m).to eql([Post.find(1), {status: :notified}])
    end


    it "rejects bad input" do
      obj = Post.new
      expect { Lifesaver::Marshal.load(obj) }.to raise_error
    end
  end

  describe ".dump" do
    it "decomposes an object to a Hash" do
      obj = Post.create(title: "Test Post")
      out = { class: :post, id: 2 }
      expect(Lifesaver::Marshal.dump(obj)).to eql(out)
    end

    it "adds additional key, value pairs if passed" do
      obj = Post.create(title: "Test Post")
      out = { status: :updated, class: :post, id: 2 }
      expect(Lifesaver::Marshal.dump(obj, {status: :updated})).to eql(out)
    end
  end
end