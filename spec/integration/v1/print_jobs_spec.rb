require "swagger_helper"

describe 'Print Jobs API' do

  path '/v1/print_jobs' do

    post 'Creates a Print Job' do
      tags 'PrintJobs'
      consumes 'application/vnd.api+json'
      produces 'application/vnd.api+json'

      parameter name: :print_job, in: :body, schema: {
        type: :object,
        properties: {
          data: {
            type: :object,
            properties: {
              type: { type: :string, default: "print_job"},
              attributes: {
                type: :object,
                properties: {
                  printer_name: { type: :string },
                  label_template_id: { type: :integer },
                  labels: { type: :object}
                },
                required: ['printer_name', 'label_template_id', 'labels']
              }
            }
          }
        }
      }

      response '201', 'print job created' do

        let(:print_job) { { data: { attributes: attributes_for(:print_job) } } }

        before do |example|
          allow_any_instance_of(LabelPrinter::PrintJob::LPD).to receive(:execute).and_return(true)
          submit_request(example.metadata)
        end

        it 'returns a valid 201 response' do |example|
          assert_response_matches_metadata(example.metadata)
        end

      end

      response '422', 'printer does not exist' do
        let(:printer_name) { build(:printer).name}
        let(:print_job) { { data: { attributes: attributes_for(:print_job).merge(printer_name: printer_name) } } }
        run_test!
      end

      response '422', 'label template does not exist' do
        let(:print_job) { { data: { attributes: attributes_for(:print_job).except(:label_template_id) } } }
        run_test!
      end

      response '422', 'labels are empty' do
        let(:print_job) { { data: { attributes: attributes_for(:print_job).merge(labels: {}) } } }
        run_test!
      end

    end
  end
end