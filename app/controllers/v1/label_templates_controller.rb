module V1
  class LabelTemplatesController < ApplicationController

    # '**' includes all nested associated resources in the "included" member
    def index
      render json: LabelTemplate.filter(filter_parameters[:filter]),
              include: '**'
    end

    def show
      render json: current_resource, include: '**'
    end

    def create
      label_template = LabelTemplate.new label_template_params
      if label_template.save
        render json: label_template, include: '**', status: :created
      else
        render_error label_template
      end
    end

    def update
      label_template = current_resource
      if label_template.update_attributes(label_template_params)
        render json: label_template, include: '**'
      else
        render_error label_template
      end
    end

    def destroy
      label_template = current_resource
      begin
        label_template.destroy!
        render json: label_template
      rescue ActiveRecord::RecordNotDestroyed
        render_error label_template
      end
    end

    def copy
      label_template = current_resource
      copy = label_template.copy(label_template_params[:name])
      render json: copy, status: :created
    end

    private

    def current_resource
      LabelTemplate.find(params[:id]) if params[:id]
    end

    def label_template_params
      begin
        params.require(:data).require(:attributes)
              .permit(LabelTemplate.permitted_attributes)
      rescue ActionController::ParameterMissing
        {}
      end
    end

    def filter_parameters
      params.permit(filter: [:name])
    end
  end
end
