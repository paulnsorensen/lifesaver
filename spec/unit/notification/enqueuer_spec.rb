require 'spec_helper'

describe Lifesaver::Notification::Enqueuer do
  let(:models) { [Lifesaver::SerializedModel.new('TestClass', '3')] }
  let(:enqueuer) { Lifesaver::Notification::Enqueuer.new(models) }
  before { ::Resque.stub(:enqueue) }

  describe '#enqueue' do
    context 'when indexing is not suppressed' do
      context 'and there are models' do
        it 'calls Resque.enqueue with the correct parameters' do
          expect(::Resque).to receive(:enqueue)
            .with(Lifesaver::VisitorWorker, models)

          enqueuer.enqueue
        end
      end
      context 'and there are no models' do
        it 'does not call Resque.enqueue' do
          empty_enqueuer = Lifesaver::Notification::Enqueuer.new([])

          expect(::Resque).to_not receive(:enqueue)

          empty_enqueuer.enqueue
        end
      end
    end

    context 'when indexing is suppressed' do
      it 'does not call Resque.enqueue' do
        Lifesaver.suppress_indexing

        expect(::Resque).to_not receive(:enqueue)

        enqueuer.enqueue
      end
    end
  end
end
