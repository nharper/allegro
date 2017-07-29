class Api::RehearsalsController < ApplicationController
  def index
    @rehearsals = Rehearsal.all
    render :json => @rehearsals
  end
end
