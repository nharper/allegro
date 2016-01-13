class ConcertsController < ApplicationController

  def attendance
    @concert = Concert.find(params[:id])
    render 'empty_list' and return unless @concert

    @sections = Registration::SECTION_TO_FULL
    @performers = []
    @records = {}
    Registration.where(:concert => @concert, :status => 'active').includes(:performer).order(:chorus_number).each do |registration|
      performer = registration.performer.attributes
      performer.delete('photo')
      @records[performer['id']] = {}
      performer['chorus_number'] = registration.chorus_number
      performer['section'] = registration.section_from_number
      @performers << performer
    end
    @rehearsals = @concert.rehearsals.order(:start_date)

    AttendanceRecord.where(:performer => @performers.map{|performer| performer['id']}, :rehearsal => @rehearsals).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
