# set up currency conversion
require 'money/bank/google_currency'

Money.default_bank = Money::Bank::GoogleCurrency.new
Money::Bank::GoogleCurrency.ttl_in_seconds = 86400
