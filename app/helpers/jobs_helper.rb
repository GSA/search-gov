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
      when 'Per Year', 'Per Hour'
        period = job.rate_interval_code == 'Per Year' ? 'yr' : 'hr'
        plus = max > job.minimum ? '+' : ''
        "#{min_str}#{plus}/#{period}"
      when 'Without Compensation'
        nil
      else
        with_max = max > job.minimum ? "-#{max_str} " : ' '
        "#{min_str}#{with_max}#{job.rate_interval_code}"
    end
  end

  def format_locations(locations)
    locations.many? ? "Multiple Locations" : locations.first
  end

  def usajobs_logo
    link_to 'https://www.usajobs.gov/', class: 'usajobs-logo' do
      image_tag 'searches/usajobs.jpg', alt: 'USAJobs.gov'
    end
  end

  def jobs_content_heading_css_classes
    css_classes = 'content-heading'
    css_classes << ' usajobs'
    css_classes
  end

  def link_to_more_jobs(search)
    title, url = more_jobs_title_and_url search
    link_to_result_title title, url, 0, 'JOBS'
  end

  def legacy_link_to_more_jobs(search)
    title, url = more_jobs_title_and_url search
    job_link_with_click_tracking title,
                                 url,
                                 search.affiliate,
                                 search.query,
                                 agency_jobs_link_index = -1,
                                 @search_vertical
  end

  def more_jobs_title_and_url(search)
    if search.affiliate.has_organization_codes?
      more_agency_jobs_title_and_url search.affiliate.agency
    else
      more_federal_jobs_title_and_url
    end
  end

  def more_agency_jobs_title_and_url(agency)
    title = "#{t :'searches.more_agency_job_openings', agency: agency.abbreviation || agency.name}"
    title << " #{t :'searches.on_usajobs'}"

    url = url_for_more_agency_jobs agency
    [title, url]
  end

  def more_federal_jobs_title_and_url
    title = t :'searches.more_federal_job_openings'
    url = 'https://www.usajobs.gov/Search/Results?hp=public'
    [title, url]
  end

  def url_for_more_agency_jobs(agency)
    organization_codes = agency.joined_organization_codes('&a=')
    "https://www.usajobs.gov/Search/Results?a=#{organization_codes}&hp=public"
  end

  def job_openings_header(agency)
    at = agency.nil? ? '' : t(:at_agency, agency: agency.abbreviation || agency.name)
    job_openings = at.present? ? t(:job_openings) : t(:federal_job_openings)
    "#{job_openings} #{content_tag(:span, h(at), class: 'jobs-agency').html_safe}".html_safe
  end
end
