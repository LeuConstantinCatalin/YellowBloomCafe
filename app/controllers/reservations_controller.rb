class ReservationsController < ApplicationController
  def create
    unless current_user
      render json: { error: 'Trebuie să fii autentificat.' }, status: :unauthorized and return
    end

    begin
      date_str = params[:date].to_s
      time_str = params[:time].to_s
      seats = params[:seats].to_i
      if date_str.blank? || time_str.blank? || seats <= 0
        render json: { error: 'Date invalide pentru rezervare.' }, status: :unprocessable_entity and return
      end
      starts_at = Time.zone.parse("#{date_str} #{time_str}")
      if starts_at.nil? || starts_at < Time.current
        render json: { error: 'Selectează o dată/ora în viitor.' }, status: :unprocessable_entity and return
      end

      r = current_user.reservations.create!(starts_at: starts_at, seats: seats, status: 'requested')
      render json: { ok: true, reservation_id: r.id }
    rescue => e
      Rails.logger.error("Reservation create failed: #{e.class} #{e.message}")
      render json: { error: 'Nu s-a putut crea rezervarea.' }, status: :internal_server_error
    end
  end
end

