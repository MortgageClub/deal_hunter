class GenerateReportService
  def self.call(hunted_count, total_count, homes)
    report = Report.new(result: "#{hunted_count} / #{total_count}", raw_data: homes.to_s)
    report.save
  end
end