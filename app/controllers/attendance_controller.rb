class AttendanceController < ApplicationController
  def home
  end

  def list
    @performers = Concert.current.performers
    @rehearsals = Concert.current.rehearsals
    @records = {}
    @performers.each do |performer|
      @records[performer.id] = {}
    end
    AttendanceRecord.where(:performer => @performers, :rehearsal => @rehearsals).each do |record|
      @records[record.performer.id][record.rehearsal.id] = record
    end
  end
end
