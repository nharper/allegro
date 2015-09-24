class AttendanceController < ApplicationController
  def home
    @next_rehearsal = Rehearsal.where('date > ?', DateTime.now).order('date ASC').first
    @prev_rehearsal = Rehearsal.where('date < ?', DateTime.now).order('date DESC').first
  end

  def list
    @registrations = Registration.current.order(:chorus_number)
    @rehearsals = Concert.current.rehearsals.order(:date)
    @performers = []
    @records = {}
    @registrations.each do |registration|
      @performers << registration.performer
      @records[registration.performer.id] = {}
    end
    AttendanceRecord.where(:performer => @performers, :rehearsal => @rehearsals).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
