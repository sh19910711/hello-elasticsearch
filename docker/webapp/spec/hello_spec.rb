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
    client.index(
      index: index,
      body: {
        hello: 'world',
      }
    )
  end

  before do
    client.indices.refresh(index: index)
  end

  after do
    client.indices.delete(index: index)
  end

  context 'search world' do
    subject { client.search(index: index, q: 'world')['hits']['hits'].first['_source']['hello'] }
    it { should eq 'world' }
  end
end
