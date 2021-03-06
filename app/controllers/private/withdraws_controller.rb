module Private
  class WithdrawsController < BaseController
    before_action :auth_activated!
    before_action :auth_verified!
    before_action :verify_two_factor!, only: :update

    def index
      @channels = WithdrawChannel.all
    end

    def create
      @withdraw = Withdraw.new(withdraw_params)

      if @withdraw.save
        redirect_to edit_withdraw_path(@withdraw)
      else
        path = :"new_withdraws_#{@withdraw.channel.key}_path"
        redirect_to send(path), notice: @withdraw.errors.full_messages.join('<br>').html_safe
      end
    end

    def edit
      @withdraw = current_user.withdraws.find(params[:id])
    end

    def update
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.submit!
      path = :"new_withdraws_#{@withdraw.channel.key}_path"
      redirect_to send(path), notice: t('.request_accepted')
    end

    def destroy
      @withdraw = current_user.withdraws.find(params[:id])
      @withdraw.cancel!
      path = :"new_withdraws_#{@withdraw.channel.key}_path"
      redirect_to send(path), notice: t('.request_canceled')
    end

    private
    def load_history
      page = params[:page] || 0
      per = params[:per] || 10

      grid = "#{controller_name}WithdrawsGrid".camelize.safe_constantize
      @withdraws_grid = grid.new(params[:withdraws_grid]) do |scope|
        scope.where(member: current_user).page(page).per(per)
      end
    end

    def withdraw_params
      params[:withdraw][:member_id] = current_user.id
      params.require(:withdraw).permit(:member_id, :currency, :sum, :type,
                                       :fund_uid, :fund_extra, :save_fund_source)
    end
  end
end
