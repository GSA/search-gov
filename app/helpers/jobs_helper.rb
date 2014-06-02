module JobsHelper
  def job_url(job)
    job.id =~ /^usajobs/ ? "#{job.url}?PostingChannelID=USASearch" : job.url
  end

  def title_link(job, search, index)
    url = job_url job
    job_link_with_click_tracking(job.position_title.html_safe, url,
                                 search.affiliate, search.query, index, @search_vertical)
  end

  def job_application_deadline(yyyy_mm_dd)
    if yyyy_mm_dd
      html = content_tag(:span, '&nbsp;&nbsp;&bull;&nbsp;&nbsp;'.html_safe, class: 'field-separator')
      html << "Apply by #{Date.parse(yyyy_mm_dd).to_s(:long)}"
    end
  end

  def locations_and_salary(job)
    content = h(format_locations(job.locations))
    salary_str = format_salary(job)
    (content << " &nbsp;&nbsp;&bull;&nbsp;&nbsp; ".html_safe << h(salary_str)) if salary_str.present?
    content
  end

  def format_salary(job)
    return if job.minimum.nil? || job.minimum.zero?
    max = job.maximum || 0
    min_str = number_to_currency(job.minimum)
    max_str = number_to_currency(job.maximum)
    case job.rate_interval_code
      when 'PA', 'PH'
        period = job.rate_interval_code == 'PA' ? 'yr' : 'hr'
        plus = max > job.minimum ? '+' : ''
        "#{min_str}#{plus}/#{period}"
      when 'WC'
        nil
      else
        with_max = max > job.minimum ? "-#{max_str} " : ' '
        "#{min_str}#{with_max}#{Jobs::RATE_INTERVALS[job.rate_interval_code.to_sym]}"
    end
  end

  def format_locations(locations)
    locations.many? ? "Multiple Locations" : locations.first
  end

  def agency_jobs_title_and_url(search)
    title = t(:see_all_federal_job_openings)
    url = 'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch'
    agency = search.affiliate.agency
    if agency.present?
      title = "#{t :see_all_agency_job_openings, agency: agency.abbreviation || agency.name}"
      url = url_for_agency_jobs(agency, search.jobs.first.id)
    end
    [title, url]
  end

  def agency_jobs_link(search)
    title, url = agency_jobs_title_and_url search
    job_link_with_click_tracking title, url, search.affiliate, search.query, agency_jobs_link_index = -1, @search_vertical
  end

  def link_to_agency_jobs_link(search)
    title, url = agency_jobs_title_and_url search
    css_classes = nil
    if url.start_with?('https://www.usajobs.gov')
      title = h(title) << "\n" << content_tag(:span, 'USAJOBS')
      css_classes = 'usajobs'
    end
    link_to_result_title(nil, title, url, 0, 'JOBS', class: css_classes)
  end

  def url_for_agency_jobs(agency, job_id)
    case job_id
    when /^usajobs/
      "https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=#{agency.organization_code}&PostingChannelID=USASearch&ApplicantEligibility=all"
    when /^ng:/
      ng_agency = job_id.split(':')[1]
      "http://agency.governmentjobs.com/#{ng_agency}/default.cfm"
    end
  end

  def job_openings_header(agency)
    at = agency.nil? ? '' : t(:at_agency, agency: agency.abbreviation || agency.name)
    job_openings = at.present? ? t(:job_openings) : t(:federal_job_openings)
    "#{job_openings} #{content_tag(:span, h(at), class: 'jobs-agency').html_safe}".html_safe
  end
end
