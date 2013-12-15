require 'spec_helper'

describe Lifesaver::Indexing::Indexer do
  context '#perform' do
    let(:index) { double('index', remove: nil, store: nil) }
    let(:index_name) { 'test-index-name' }
    before do
      Model.stub(:index_name).and_return(index_name)
      Tire.stub(:index).with(index_name).and_return(index)
    end

    context 'when operation is update' do
      let(:model) { Model.new(1) }
      before do
        Model.stub(:exists?).with('1').and_return(true)
        Model.stub(:find).with('1').and_return(model)
      end

      it 'calls tire with the correct arguments' do
        indexer = Lifesaver::Indexing::Indexer.new(
                                                    class_name: 'model',
                                                    model_id: '1',
                                                    operation: 'update'
                                                   )

        expect(index).to receive(:store).with(model)

        indexer.perform
      end
    end

    context 'when operation is destroy' do
      before do
        Model.stub(:document_type).and_return('class')
      end

      it 'calls tire with the correct arguments' do
        indexer = Lifesaver::Indexing::Indexer.new(
                                                    class_name: 'model',
                                                    model_id: '1',
                                                    operation: 'destroy'
                                                   )
        correct_arguments = { type: 'class', id: '1' }

        expect(index).to receive(:remove).with(correct_arguments)

        indexer.perform
      end
    end
  end
end
