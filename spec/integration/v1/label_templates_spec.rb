require "swagger_helper"

describe 'Label Templates API' do

  path '/v1/label_templates' do

    get 'Fetches Label Templates' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      response '200', 'label templates found' do
        schema type: :object, properties: {
          data: {
            type: :array,
            items: {
              type: :object,
              properties: {
                id: { type: :integer },
                type: { type: :string, default: "label Templates" },
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

    get 'Fetches Label Templates by Name' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: 'filter[name]', in: :query, type: 'string'

      response '200', 'Label Template found' do

        let!(:label_templates) { create_list(:label_template, 5) }
        let('filter[name]') { label_templates.first.name }

        before do |example|
          submit_request(example.metadata)
        end

        it 'returns only label template for specified name' do
          json = ActiveSupport::JSON.decode(response.body)
          expect(json["data"].length).to eq(1)
          expect(json["data"][0]["id"]).to eq(label_templates.first.id.to_s)
          expect(json["data"][0]["attributes"]["name"]).to eq(label_templates.first.name)
        end
      end
    end
  end
end