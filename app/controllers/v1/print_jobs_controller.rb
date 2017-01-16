module V1
  class PrintJobsController < ApplicationController

    def create
      print_job = LabelPrinter::PrintJob.build(print_job_params)
      if print_job.execute
        render json: print_job, serializer: PrintJobSerializer, status: :created
      else
        render_error print_job
      end
    end

    private

    # TODO: At the moment we have to permit all of the labels attributes
    # There needs to be a way of whitelisting only the attributes that are needed
    # for each print job
    def print_job_params
      params.require(:data).require(:attributes)
            .permit(:printer_name, :label_template_id, :labels)
            .tap do |whitelisted|
              whitelisted[:labels] = params[:data][:attributes][:labels]
              whitelisted.permit!
            end
    end
  end
end
