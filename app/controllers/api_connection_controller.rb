class ApiConnectionController < ApplicationController

  def new
    @hostname = HerokuConnection.call
  end
end