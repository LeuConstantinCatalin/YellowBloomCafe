class MessagesController < ApplicationController
  def create
    unless current_user
      redirect_to account_path, alert: "Trebuie să fii autentificat." and return
    end
    unless current_user.client?
      redirect_to root_path, alert: "Doar clienții pot trimite mesaje aici." and return
    end
    m = current_user.messages.build(message_params)
    if m.save
      redirect_to account_path, notice: "Mesaj trimis. Mulțumim!"
    else
      redirect_to account_path, alert: m.errors.full_messages.join(', ')
    end
  end

  private

  def message_params
    params.require(:message).permit(:subject, :content)
  end
end

