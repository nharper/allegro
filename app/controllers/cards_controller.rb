class CardsController < ApplicationController
  def create
    card = Card.create(params[:card].permit(:card_id, :performer_id).merge(:active => true))
    if !card.valid?
      flash[:error] = 'Error creating new card'
    end
    redirect_to cards_path
  end

  def index
    respond_to do |format|
      format.html do
        @registrations = Registration.where(:concert => Concert.current).order('chorus_number').includes(:performer)

        # Group cards by performer
        @cards = {}
        Card.all.each do |card|
          @cards[card.performer_id] = [] unless @cards[card.performer_id]
          @cards[card.performer_id] << card
        end

        # Group registrationless performers:
        @other_performers = Performer.where.not(:id => Registration.where(:concert => Concert.current).pluck(:performer_id)).order('name')

      end
      format.json do
        @cards = Card.select(:card_id, :performer_id).where(:active => true)
        render :json => @cards
      end
    end
  end

  def destroy
    card = Card.find(params[:id])
    if !card.destroy
      flash[:error] = 'Error deleting card'
    end
    redirect_to cards_path
  end
end
