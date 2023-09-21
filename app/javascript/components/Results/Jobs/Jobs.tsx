import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { useCollapse } from 'react-collapsed';

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
  recommendedBy: string;
  jobs?: jobType;
}

export const Jobs = ({ recommendedBy, jobs=[] }: JobsProps) => {
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
                  Job Openings at {recommendedBy}
                </h2>
              </Grid>
              <Grid col={true} className='jobs-logo-wrapper'>
                <a className="usajobs-logo" href="https://www.usajobs.gov/">
                  <img alt="USAJobs.gov" src="https://d15vqlr7iz6e8x.cloudfront.net/assets/searches/usajobs-bab6b21076d3a8fdf0808ddbde43f24858db74b226057f19daa10ef3b3fba090.jpg" />
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
                        <li>{job.minimumPay}-{job.maximumPay} {job.rateIntervalCode}</li>
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
                            <li>{job.minimumPay}-{job.maximumPay} {job.rateIntervalCode}</li>
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
                      More federal job openings on USAJobs.gov
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
