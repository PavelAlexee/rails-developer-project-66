# frozen_string_literal: true

class Web::Repositories::ApplicationController < Web::ApplicationController
  before_action :authenticate_user
end
