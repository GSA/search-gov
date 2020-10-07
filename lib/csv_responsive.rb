# frozen_string_literal: true

module CSVResponsive
  def csv_response(filename, header, arr)
    respond_to do |format|
      format.csv { export_csv(filename, header, arr) }
    end
  end

  def export_csv(filename, header, rows)
    file = CSV.generate do |csv|
      csv << header if header.present?
      rows.each { |row| csv << row }
    end

    send_data(
      file,
      type: 'text/csv; charset=utf-8; header=present',
      disposition: "attachment;filename=#{filename}.csv"
    )
  end

  def format_modules(modules)
    Array(modules).join(' ')
  end
end
