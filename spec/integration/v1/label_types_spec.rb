require "swagger_helper"

describe 'Label Types API' do

  path '/v1/label_types' do

    get 'Fetches Label Types' do
      tags 'LabelTypes'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      response '200', 'label types found' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                type: { type: :string, default: "label types" },
                attributes: {
                  type: :object,
                  properties: {
                    name: { type: :string }
                  }
                }
              }
            }
          }
        }

        run_test!
      end

    end

    get 'Fetches Label Types by name' do
      tags 'LabelTypes'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'filter[name]', in: :query, type: 'string'

      response '200', 'Label Type found' do

        let!(:label_types) { create_list(:label_type, 5) }

        let('filter[name]') { label_types.first.name }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns only label types for specified name' do
          json = ActiveSupport::JSON.decode(response.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(label_types.first.id.to_s)
          expect(json["data"][0]["attributes"]["name"]).to eq(label_types.first.name)
        end

      end
    end

    post 'Creates a Label Type' do
      tags 'LabelTypes'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :label_type, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, default: "label_types"},
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  feed_value: { type: :string },
                  fine_adjustment: { type: :string },
                  pitch_length: { type: :string },
                  print_width: { type: :string },
                  print_length: { type: :string }
                },
                required: ['name', 'feed_value', 'fine_adjustment', 'pitch_length', 'print_width', 'print_length']
              }
            }
          }
        }
      }

      response '201', 'label type created' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type) } } }
        run_test!
      end

      response '422', 'name can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:name) } } }
        run_test!
      end

      response '422', 'feed value can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:feed_value) } } }
        run_test!
      end

      response '422', 'fine adjustment can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:fine_adjustment) } } }
        run_test!
      end

      response '422', 'pitch length can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:pitch_length) } } }
        run_test!
      end

      response '422', 'print width can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:print_width) } } }
        run_test!
      end

      response '422', 'print length can\'t be blank' do
        let(:label_type) { { data: { attributes: attributes_for(:label_type).except(:print_length) } } }
        run_test!
      end

    end

  end

  path '/v1/label_types/{id}' do

    get 'Retrieves a Label Type' do
      tags 'LabelTypes'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'label type found' do
        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string, default: "label_types" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  feed_value: { type: :string },
                  fine_adjustment: { type: :string},
                  pitch_length: { type: :string},
                  print_width: { type: :string},
                  print_length: { type: :string}
                }
              }
            }
          }
        }

        let(:id) { create(:label_type).id }

        run_test!
      end
    end
  end
end