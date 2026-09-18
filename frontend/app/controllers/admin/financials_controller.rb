class Admin::FinancialsController < Admin::BaseController
  def index
    @financial_report = AdminFinancialReport.new.call
    @treasury_snapshot = TreasurySnapshotService.new.call(tokens: @financial_report[:tokens].map { |row| row[:token] })
  end
end