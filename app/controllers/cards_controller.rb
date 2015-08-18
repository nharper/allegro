class CardsController < ApplicationController
  def new
    @performers = Performer.where.not(:id => Card.where(:active => true).pluck(:performer_id))
  end

  def create
    if !Card.create(params[:card].permit(:card_id, :performer_id).merge(:active => true))
      flash[:error] = 'Error creating new card'
    end
    redirect_to cards_path
  end

  def index
    @cards = Card.all.includes(:performer).order(:active => :desc)
  end
end
