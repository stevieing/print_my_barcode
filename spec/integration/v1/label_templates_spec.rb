require "swagger_helper"

describe 'Label Templates API', helpers: :true do

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
                type: { type: :string, default: "label_templates" },
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

    post 'Creates a Label Template' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :label_template, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, default: "label_templates"},
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  label_type_id: { type: :string },
                  labels_attributes: { 
                    type: :array,
                    items: {
                      type: :object,
                      properties: {
                        name: { type: :string },
                        bitmaps_attributes: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              field_name: { type: :string},
                              x_origin: { type: :string },
                              y_origin: { type: :string },
                              horizontal_magnification: { type: :string },
                              vertical_magnification: { type: :string },
                              font: { type: :string },
                              space_adjustment: { type: :string },
                              rotational_angles: { type: :string }
                            }
                          }
                        },
                        barcodes_attributes: {
                          type: :array,
                          items: {
                            type: :object,
                            properties: {
                              field_name: { type: :string},
                              x_origin: { type: :string },
                              y_origin: { type: :string },
                              barcode_type: { type: :string },
                              type_of_check_digit: { type: :string },
                              one_module_width: { type: :string },
                              one_cell_width: { type: :string },
                              rotational_angle: { type: :string },
                              height: { type: :string },
                              no_of_columns: { type: :string },
                              bar_heigth: { type: :string }
                            }
                          }
                        }
                      }
                    } 
                  },
                },
                required: ['name', 'label_type_id', 'labels_attributes']
              }
            }
          }
        }
      }

      response '201', 'label template created' do
        let(:label_template) { label_template_params }
        run_test!
      end

      response '422', 'name can\'t be blank' do
        let(:label_template) { { data: { attributes: label_template_params_with_invalid_name } } }
      end
    end

   
  end

  #TODO: add correct attributes
  path '/v1/label_templates/{id}' do

    get 'Retrieves a Label Template' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'label template found' do
        schema type: :object, properties: {
          data: {
            type: :object,
            properties: {
              id: { type: :string },
              type: { type: :string, default: "label_templates" },
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string },
                  published: { type: :boolean }
                }
              }
            }
          }
        }

        let(:id) { create(:label_template).id }

        run_test!

      end
    end

    patch 'Updates a Label Template' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'label template updated' do

        let(:id) { create(:label_template).id }
        let(:label_type) { create(:label_type)}
        let(:label_template) { { data: { attributes: { label_type_id: label_type.id }}}}

        run_test!

      end
    end

    delete 'Deletes a Label Template' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      response '200', 'label template deleted' do

        let(:id) { create(:label_template).id }

        run_test!

      end
    end

  end
end