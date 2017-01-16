module V1
  # using ActionController::API will not
  # allow template rendering.
  # TODO: move docs to swagger
  class DocsController < ActionController::Base

    def index
      render layout: false
    end
  end
end
