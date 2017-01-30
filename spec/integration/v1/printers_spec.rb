require "swagger_helper"

describe 'Printers API' do

  path '/v1/printers' do

    get 'Fetches printers' do
      tags 'Printers'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      response '200', 'printers found' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                type: { type: :string, default: "printers" },
                attributes: {
                  type: :object,
                  properties: {
                    name: { type: :string },
                    protocol: { type: :string}
                  }
                }
              }
            }
          }
        }

        run_test!
      end

    end

    get 'Fetches Printers by protocol' do
      tags 'Printers'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'filter[protocol]', in: :query, type: 'string'

      response '200', 'LPD printers found' do

        let('filter[protocol]') { 'LPD' }
        let!(:lpd_printers) { create_list(:printer, 3) }
        let!(:ipp_printers) { create_list(:printer, 3, protocol: 'IPP') }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns only printers for specified protocol' do
          expect(ActiveSupport::JSON.decode(response.body)["data"].length).to eq(3)
        end

      end

    end

    get 'Fetches Printers by name' do
      tags 'Printers'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'filter[name]', in: :query, type: 'string'

      response '200', 'printer found' do

        let!(:printers) { create_list(:printer, 5) }

        let('filter[name]') { printers.first.name }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns only printers for specified name' do
          json = ActiveSupport::JSON.decode(response.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(printers.first.id.to_s)
          expect(json["data"][0]["attributes"]["name"]).to eq(printers.first.name)
        end

      end

    end

    post 'Creates a printer' do
      tags 'Printers'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :printer, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, default: "printers"},
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  protocol: { type: :string, default: "LPD" }
                },
                required: ['name']
              }
            }
          }
        }
      }

      response '201', 'printer created' do
        let(:printer) { { data: { attributes: attributes_for(:printer) } } }
        run_test!
      end

      response '422', 'name can\'t be blank' do
        let(:printer) { { data: { attributes: { name: nil } } } }
        run_test!
      end

    end

  end

  path '/v1/printers/{id}' do

    get 'Retrieves a printer' do
      tags 'Printers'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'printer found' do
        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string, default: "printers" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  protocol: { type: :string}
                }
              }
            }
          }
        }

        let(:id) { create(:printer).id }

        run_test!
      end
    end
  end
end