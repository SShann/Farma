class Sequence::SequenceController < ApplicationController

  def calculates
    #puts "====="
    #puts "team_id #{params[:team_id]}"
    #puts "lo_id #{params[:lo_id]}"
    statistic = Sequence::Statistic.find_or_create_by(lo_id: params[:lo_id],
                                                      team_id: params[:team_id])
    statistic.calculate_statistics
    render nothing: true
  end

end
