module UsajobsHelper
  def job_position_title(job)
    link_to(job.position_title.html_safe, "https://www.usajobs.gov/GetJob/ViewDetails/#{job.id}")
  end

  def job_application_deadline(yyyy_mm_dd)
    "Apply by #{Date.parse(yyyy_mm_dd).to_s(:rfc822)}"
  end

  def job_position_locations_and_salary(job)
    location_str = job.locations.many? ? "Multiple Locations" : job.locations.first
    min = number_to_currency(job.minimum, :precision => 0)
    max = number_to_currency(job.maximum, :precision => 0)
    salary_str =
      case job.rate_interval_code
        when 'PA'
          "#{min}+/yr" unless job.minimum.zero?
        when 'PH'
          "#{min}+/hr"
        when 'WC'
          nil
        else
          with_max = min == max ? ' ' : "-#{max} "
          "#{min}#{with_max}#{Usajobs::RATE_INTERVALS[job.rate_interval_code.to_sym]}"
      end
    dash_salary = salary_str.present? ? " - #{salary_str}" : ''
    "#{location_str}#{dash_salary}"
  end

  def agency_jobs_link(agency)
    link_to "See all #{agency.abbreviation || agency.name} job openings",
            "https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=#{agency.organization_code}"
  end
end