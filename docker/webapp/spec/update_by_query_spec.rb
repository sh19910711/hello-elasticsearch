require 'spec_helper'

describe do
  let(:index) { SecureRandom.uuid }

  let(:client) do
    Elasticsearch::Client.new(
      host: 'search.local:9200',
      log: true,
      trace: true,
    )
  end

  before do
    titles = [
      'foo 1',
      'foo 2',
      'bar 1',
      'bar 2',
      'bar 3',
    ]
    titles.each do |t|
      client.index(
        index: index,
        body: {
          title: t,
        }
      )
    end
    client.indices.refresh(index: index)
  end

  after(:each) do
    client.indices.delete(index: index)
  end

  context do
    let(:query) do
      {
        match: {
          title: {
            query: 'foo 2',
            operator: 'and'
          }
        }
      }
    end

    subject { client.search(index: index, body: { query: query })['hits']['hits'] }
    it { expect(subject.size).to eq 1 }
    it { expect(subject.first['_source']['num']).to be_nil }

    context do
      before do
        client.update_by_query(
          index: index,
          body: {
            query: query,
            script: {
              source: 'ctx._source.num = 123'
            }
          }
        )
        client.indices.refresh(index: index)
      end

      it { expect(subject.first['_source']['num']).to eq 123}
    end
  end
end
