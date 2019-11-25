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
    client.indices.create(
      index: index,
      body: {
        mappings: {
          properties: {
            title: {
              type: 'keyword'
            }
          }
        }
      }
    )
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

  context 'match.term.key.value' do
    let(:query) do
      {
        term: {
          title: {
            value: 'foo 1'
          }
        }
      }
    end

    let(:search_result) { client.search(index: index, body: { query: query })['hits']['hits'] }
    it { expect(search_result.size).to eq 1 }
    it { expect(search_result.first['_source']['num']).to be_nil }
  end

  context 'match.key.query' do
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

    let(:search_result) { client.search(index: index, body: { query: query })['hits']['hits'] }
    it { expect(search_result.size).to eq 1 }
    it { expect(search_result.first['_source']['num']).to be_nil }

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

      it { expect(search_result.first['_source']['num']).to eq 123}
    end
  end
end
