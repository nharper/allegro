class AttendanceController < ApplicationController
  def home
    @concerts = Concert.active
    @next_rehearsal = Rehearsal.where('start_date > ?', DateTime.now).order('start_date ASC').first
    @prev_rehearsal = Rehearsal.where('start_date < ?', DateTime.now).order('start_date DESC').first
  end

  def list
    render 'empty_list' and return unless Concert.current

    @sections = Registration::SECTION_TO_FULL
    @performers = []
    @records = {}
    Registration.current.order(:chorus_number).each do |registration|
      performer = registration.performer.attributes
      performer.delete('photo')
      @records[performer['id']] = {}
      performer['chorus_number'] = registration.chorus_number
      performer['section'] = registration.section_from_number
      @performers << performer
    end
    @rehearsals = Concert.current.rehearsals.order(:start_date)

    AttendanceRecord.where(:performer => @performers.map{|performer| performer['id']}, :rehearsal => @rehearsals).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
