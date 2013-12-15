require 'spec_helper'

describe Lifesaver::Notification::IndexingGraph do
  let(:indexing_graph) { Lifesaver::Notification::IndexingGraph.new }

  describe '#initalize_models' do
    it 'should load serialized models into the loader' do
      indexing_graph.stub(:add_model_to_loader)
      serialized_models = []
      serialized_models << Lifesaver::SerializedModel.new('Post', 14)

      expect(indexing_graph).to receive(:add_model_to_loader).with('Post', 14)

      indexing_graph.initialize_models(serialized_models)
    end
  end

  describe '#generate' do
    context 'when queue is empty' do
      before do
        indexing_graph.stub(:queue_full?).and_return(false)
      end

      context 'and loader is empty' do
        it 'exits and returns models_to_index' do
          indexing_graph.stub(:loader_full?).and_return(false)
          indexing_graph.stub(:models_to_index).and_return([Model.new(15)])

          expect(indexing_graph.generate).to eql([Model.new(15)])
        end
      end

      context 'and loader is not empty' do
        it 'calls load_into_queue' do
          indexing_graph.stub(:loader_full?).and_return(true, false)
          indexing_graph.stub(:load_into_queue)

          expect(indexing_graph).to receive(:load_into_queue)

          indexing_graph.generate
        end
      end
    end

    context 'when queue is not empty' do
      before do
        indexing_graph.stub(:queue_full?).and_return(true, false)
        indexing_graph.stub(:pop_model).and_return(Model.new(1))
        indexing_graph.stub(:add_unvisited_associations)
      end

      it 'adds model if should be indexed' do
        indexing_graph.stub(:model_should_be_indexed?).and_return(true)

        expect(indexing_graph.generate).to eql([Model.new(1)])
      end

      it 'does not add a model if it should not be indexed' do
        indexing_graph.stub(:model_should_be_indexed?).and_return(false)

        expect(indexing_graph.generate).to eql([])
      end

      it 'adds unvisited associations to the graph' do
        indexing_graph.stub(:model_should_be_indexed?).and_return(false)

        expect(indexing_graph).to receive(:add_unvisited_associations)

        indexing_graph.generate
      end
    end
  end
end
