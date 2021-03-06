module Private::Withdraws
  class SatoshiController < ::Private::WithdrawsController
    def new
      @channel = WithdrawChannelSatoshi.get
      @account = current_user.get_account(@channel.currency)
      @withdraw = ::Withdraws::Satoshi.new currency: @channel.currency, account: @account
      @fund_sources = current_user.fund_sources.with_channel(@channel.id)
      load_history
    end
  end
end
