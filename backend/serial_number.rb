class SerialNumber
  @next_serial = 0;

  def self.nextSerialNumber
    @next_serial = @next_serial + 1
    @next_serial
  end
end
