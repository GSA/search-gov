module UsajobsHelper
  def title_link(job)
    link_to(job.position_title.html_safe, "https://www.usajobs.gov/GetJob/ViewDetails/#{job.id}?PostingChannelID=USASearch")
  end

  def job_application_deadline(yyyy_mm_dd)
    "Apply by #{Date.parse(yyyy_mm_dd).to_s(:long)}"
  end

  def locations_and_salary(job)
    content = h(format_locations(job.locations))
    salary_str = format_salary(job)
    (content << " &nbsp;&nbsp;&bull;&nbsp;&nbsp; ".html_safe << h(salary_str)) if salary_str.present?
    content
  end

  def format_salary(job)
    min = number_to_currency(job.minimum, :precision => 0)
    max = number_to_currency(job.maximum, :precision => 0)
    case job.rate_interval_code
      when 'PA', 'PH'
        period = job.rate_interval_code == 'PA' ? 'yr' : 'hr'
        plus = min == max ? '' : '+'
        "#{min}#{plus}/#{period}" unless job.minimum.zero?
      when 'WC'
        nil
      else
        with_max = min == max ? ' ' : "-#{max} "
        "#{min}#{with_max}#{Usajobs::RATE_INTERVALS[job.rate_interval_code.to_sym]}"
    end
  end

  def format_locations(locations)
    locations.many? ? "Multiple Locations" : locations.first
  end

  def agency_jobs_link(agency)
    if agency.present?
      link_to "See all #{agency.abbreviation || agency.name} job openings",
              "https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=#{agency.organization_code}&PostingChannelID=USASearch"
    else
      link_to 'All federal job openings', 'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch'
    end
  end

  def job_openings_header(agency)
    at = agency.nil? ? '' : " at #{agency.abbreviation || agency.name}"
    job_openings = at.present? ? 'Job Openings' : 'Federal Job Openings'
    "#{job_openings}#{content_tag(:span, h(at), class: 'jobs-agency').html_safe}".html_safe
  end
end