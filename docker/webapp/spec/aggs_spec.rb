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

  let(:documents) do
    list = []
    list.append({
      id: SecureRandom.uuid,
      title: 'hello',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'Hello World',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'item-1',
      desc: 'Item',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'item-2',
      desc: 'Item',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'item-3',
      desc: 'Item',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'foo',
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'have-tags-1',
      tags: [],
    })
    list.append({
      id: SecureRandom.uuid,
      title: 'have-tags-2',
      tags: ['foo', 'bar'],
    })
    list
  end

  before do
    client.indices.create(
      index: index,
      body: {
        mappings: {
          properties: {
            title: {
              type: 'keyword'
            },
            tags: {
              type: 'keyword',
            }
          }
        }
      }
    )

    documents.each do |d|
      d[:tags] = [] if d[:tags].nil?
      client.index(
        index: index,
        body: d,
      )
    end
    client.indices.refresh(index: index)
  end

  context 'term query' do
    let(:search_result) do
      client.search(
        index: index,
        body: {
          query: {
            term: term_query
          }
        }
      )
    end

    context do
      let(:term_query) do
        {
          title: {
            value: 'have'
          }
        }
      end
      subject { search_result['hits']['hits'] }
      it { should be_empty }
    end

    context do
      let(:term_query) do
        {
          title: {
            value: 'foo'
          }
        }
      end
      subject { search_result['hits']['hits'] }
      it { should_not be_empty }
    end
  end

  context 'aggs' do
    let(:search_result) do
      client.search(
        index: index,
        body: {
          aggs: {
            tag_count: {
              terms: {
                field: 'tags'
              }
            }
          }
        }
      )
    end

    let(:buckets) { search_result['aggregations']['tag_count']['buckets'] }
    let(:foo) { buckets.find {|x| x['key'] == 'foo' } }
    subject { foo['doc_count'] }
    it { should eq 1 }
  end
end
