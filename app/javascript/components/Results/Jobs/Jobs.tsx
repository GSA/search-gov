import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { useCollapse } from 'react-collapsed';
import { LanguageContext } from '../../../contexts/LanguageContext';

import './Jobs.css';

type jobType = {
  positionTitle: string;
  positionUri: string;
  positionLocationDisplay: string;
  organizationName: string;
  minimumPay: number;
  maximumPay: number;
  rateIntervalCode: string;
  applicationCloseDate: string;
}[];
interface JobsProps {
  jobs?: jobType;
}

const numberToCurrency = new Intl.NumberFormat('en-US', {
    style: 'currency',
    currency: 'USD',
});

function formatSalary(job: any) {
    if (job.minimumPay === null || job.minimumPay === 0) {
      return;
    }
    let max = job.maximumPay || 0;
    let min_str = numberToCurrency.format(job.minimumPay);
    let max_str = numberToCurrency.format(job.maximumPay);
    switch (job.rateIntervalCode) {
      case 'Per Year' || 'Per Hour':
        let period = job.rateIntervalCode === 'Per Year' ? 'yr' : 'hr';
        let plus = max > job.minimumPay ? '+' : '';
        return min_str + plus + '/' + period;
      case 'Without Compensation':
        return null;
      default:
        let with_max = max > job.minimumPay ? '-' + max_str + ' ' : ' ';
        return min_str + with_max + job.rateIntervalCode;
    }
}

export const Jobs = ({ jobs=[] }: JobsProps) => {
  const i18n = useContext(LanguageContext);

  const { getCollapseProps, getToggleProps, isExpanded } = useCollapse();
  const MAX_JOBS_IN_COLLAPSE_VIEW = 3;
  let lessJobs = jobs;
  let moreJobs:jobType = [];

  if (jobs?.length > MAX_JOBS_IN_COLLAPSE_VIEW) {
    lessJobs = jobs.slice(0, MAX_JOBS_IN_COLLAPSE_VIEW);
    moreJobs = jobs.slice(MAX_JOBS_IN_COLLAPSE_VIEW, jobs.length);
  }   

  return (
    <>
      {jobs?.length > 0 && (
        <div className='search-item-wrapper search-jobs-item-wrapper'>
          <GridContainer className='jobs-title-wrapper'>
            <Grid row gap="md">
              <Grid col={true}>
                <h2 className='jobs-title-wrapper-label'>
                  {i18n.t('federalJobOpenings')}
                </h2>
              </Grid>
              <Grid col={true} className='jobs-logo-wrapper'>
                <a className="usajobs-logo" href="https://www.usajobs.gov/">
                  <img alt="USAJobs.gov" />
                </a>
              </Grid>
            </Grid>
          </GridContainer>

          {lessJobs?.map((job, index) => {
            return (
              <GridContainer className='result search-result-item' key={index}>
                <Grid row gap="md">
                  <Grid col={true} className='result-meta-data'>
                    <div className='result-title'>
                      <a href={job.positionUri} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {job.positionTitle}
                        </h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>{job.organizationName}</p>
                      <ul className="list-horizontal">
                        <li>{job.positionLocationDisplay}</li>
                        {formatSalary(job) && (<li>{formatSalary(job)}</li>)}
                        <li>Apply by {job.applicationCloseDate}</li>
                      </ul>
                    </div>
                  </Grid>
                </Grid>
                <Grid row className="row-mobile-divider"></Grid>
              </GridContainer>
            );
          })}

          {moreJobs?.length > 0 && (
            <div {...getCollapseProps()} className='collapsed-jobs-wrapper'>
              {moreJobs?.map((job, index) => {
                return (
                  <GridContainer className='result search-result-item' key={index}>
                    <Grid row gap="md">
                      <Grid col={true} className='result-meta-data'>
                        <div className='result-title'>
                          <a href={job.positionUri} className='result-title-link'>
                            <h2 className='result-title-label'>
                              {job.positionTitle}
                            </h2>
                          </a>
                        </div>
                        <div className='result-desc'>
                          <p>{job.organizationName}</p>
                          <ul className="list-horizontal">
                            <li>{job.positionLocationDisplay}</li>
                            {formatSalary(job) && (<li>{formatSalary(job)}</li>)}
                            <li>Apply by {job.applicationCloseDate}</li>
                          </ul>
                        </div>
                      </Grid>
                    </Grid>
                    <Grid row className="row-mobile-divider"></Grid>
                  </GridContainer>
                );
              })}
            </div>
          )}

          <GridContainer className='result search-result-item'>
            <Grid row className='flex-justify-center'>
              <div className="usa-nav__primary view_more_less_jobs" {...getToggleProps()}>
                <div className="usa-nav__primary-item">
                  {isExpanded ? 
                    <button className="usa-accordion__button" aria-expanded="true" type="button"><span>View Less</span></button> : 
                    <button className="usa-accordion__button" aria-expanded="false" type="button"><span>View More</span></button>
                  }
                </div>
              </div>
            </Grid>
          </GridContainer>
          
          <GridContainer className='result search-result-item'>
            <Grid row gap="md">
              <Grid col={true} className='result-meta-data'>
                <div className='result-title'>
                  <a href="https://www.usajobs.gov/Search/Results?hp=public" className='result-title-link more-jobs-title-link'>
                    <h2 className='result-title-label'>
                      {i18n.t('searches.moreFederalJobOpenings')}
                    </h2>
                  </a>
                </div>
              </Grid>
            </Grid>
          </GridContainer>
          
          <GridContainer className='result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer>
        </div>
      )}
    </>
  );
};
