require "swagger_helper"

describe 'Label Templates API' do

  def labels_attributes
    [
      {
        name: build(:label).name,
        barcodes_attributes: [ attributes_for(:barcode), attributes_for(:barcode) ],
        bitmaps_attributes: [ attributes_for(:bitmap), attributes_for(:bitmap) ]
      },
      {
        name: build(:label).name,
        barcodes_attributes: [ attributes_for(:barcode), attributes_for(:barcode) ],
        bitmaps_attributes: [ attributes_for(:bitmap), attributes_for(:bitmap) ]
      }
    ]
  end

  def invalid_label_attributes
    {
      name: build(:label).name,
      barcodes_attributes: [ attributes_for(:barcode), attributes_for(:barcode) ],
      bitmaps_attributes: [ attributes_for(:bitmap).except(:x_origin), attributes_for(:bitmap) ],
    }
  end

  def label_template_params
    label_template = build(:label_template)
    {
      name: label_template.name,
      published: label_template.published,
      label_type_id: create(:label_type).id,
      labels_attributes: labels_attributes
    }
  end

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
        let(:label_template) { { data: { attributes: label_template_params } } }
        run_test!
      end

      response '422', 'name can\'t be blank' do
        let(:label_template) { { data: { attributes: label_template_params.except(:name) } } }
        run_test!
      end

      response '422', 'label type does not exist' do
        let(:label_template) { { data: { attributes: label_template_params.except(:label_type_id) } } }
        run_test!
      end

      response '422', 'label is not valid' do
        let(:label_template) { { data: { attributes: label_template_params.merge(labels_attributes: labels_attributes.push(invalid_label_attributes)) } } }
        run_test!
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
              },
              relationships: {
                type: :object,
                properties: {
                  type: { type: :string, default: "label_type" },
                  data: {
                    type: :object,
                    properties: {
                      id: { type: :string },
                      type: { type: :string, default: "label_types" },
                      attributes: {
                        type: :object,
                        properties: {
                          labels: {
                            type: :object,
                            data: {
                              type: :array,
                              items: {
                                type: :object
                              # }
                              # items: {
                              #   type: :object #,
                                # properties: {
                                #   id: { type: :string },
                                #   type: { type: :string, default: "labels"}
                                # }
                              }
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
              included: {
                type: :array,
                items: {
                  type: :object
                }
              }
            }
          }
        }

        let(:id) { create(:label_template).id }

        run_test!

      end
    end

    #TODO: fix tests for label template with invalid attributes.
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

      response '422', 'A published label template cannot be modified' do

        let(:id) { create(:published_label_template).id }
        let(:label_type) { create(:label_type)}
        let(:label_template) { { data: { attributes: { label_type_id: label_type.id }}}}

        run_test!
      end

      # response '422', 'Invalid attributes' do
      #   let(:id) { create(:label_template).id }
      #   let(:label_template) { { data: { attributes: { label_type_id: nil }}}}

      #   run_test!
      # end
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

      response '422', 'A published label template cannot be modified' do
        
        let(:id) { create(:published_label_template).id }

        run_test!
      end
    end

  end

  path '/v1/label_templates/{id}/copy' do

    post 'Copies a label template' do
      tags 'LabelTemplates'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :id, in: :path, type: :integer

      parameter name: :label_template, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              attributes: {
                type: :object,
                properties: {
                  name: { type: :string}
                }
              }
            }
          }
        }
      }

      response '201', 'Label Template created' do
        let(:id) { create(:label_template).id }
        let(:label_template) { { data: { attributes: { name: build(:label_template).name} } } }
        run_test!
      end

      response '201', 'Label Template created' do
        let(:id) { create(:label_template).id }
        let(:label_template) { { data: { attributes: { name: "" } } } }
        run_test!
      end
    end
  end
end