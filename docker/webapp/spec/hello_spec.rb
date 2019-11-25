require 'spec_helper'

describe do
  INDEX_NAME = 'items'

  let(:client) do
    Elasticsearch::Client.new(
      host: 'search.local:9200',
      log: true,
      trace: true,
    )
  end

  before do
    begin
      client.indices.delete(index: INDEX_NAME)
    rescue Elasticsearch::Transport::Transport::Errors::NotFound => e
      puts "Ignore deleting index #{INDEX_NAME}"
    end
  end

  before do
    client.index(
      index: INDEX_NAME,
      body: {
        hello: 'world',
      }
    )
  end

  before do
    client.indices.refresh(index: INDEX_NAME)
  end

  context 'search world' do
    subject { client.search(q: 'world')['hits']['hits'].first['_source']['hello'] }
    it { should eq 'world' }
  end
end
