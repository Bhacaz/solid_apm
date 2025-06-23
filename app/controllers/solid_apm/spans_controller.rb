# frozen_string_literal: true

module SolidApm
  class SpansController < ApplicationController
    def show
      @span = SolidApm::Span.find_by!(uuid: params[:uuid])
    end
  end
end
