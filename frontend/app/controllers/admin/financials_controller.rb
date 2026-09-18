class Admin::FinancialsController < Admin::BaseController
  def index
    @financial_report = AdminFinancialReport.new.call
    @treasury_snapshot = TreasurySnapshotService.new.call(tokens: @financial_report[:tokens].map { |row| row[:token] })
  end

  def treasury_snapshot
    tokens = ApprovedToken.order(:ticker, :id).to_a
    snapshot = TreasurySnapshotService.new.call(tokens: tokens, force_refresh: true)
    render partial: 'admin/shared/treasury_strip',
           locals: { treasury: snapshot, tokens: tokens }
  end
end