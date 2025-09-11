require './serial_number.rb'
require './transaction_type.rb'

class Transaction
  attr_reader :serial_number
  attr_accessor :amount
  attr_accessor :description
  attr_accessor :status
  attr_accessor :type

  def initialize
    @serial_number = SerialNumber.nextSerialNumber
    @amount = 0.0
    @description = ''
    @status = 0
    @type = TransactionType::Other
  end
end
