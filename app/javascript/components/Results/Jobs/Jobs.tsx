import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { useCollapse } from 'react-collapsed';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { StyleContext } from '../../../contexts/StyleContext';
import { NoResults } from '../NoResults/NoResults';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from '../ResultGrid/ResultGridWrapper';
import ResultTitle from '../ResultGrid/ResultTitle';

import './Jobs.css';

import usajobsImage from 'searches/usajobs.jpg';
import { FontsAndColors } from '../../SearchResultsLayout';

type Job = {
  positionTitle: string;
  positionUri: string;
  positionLocation: string;
  organizationName: string;
  minimumPay: number;
  maximumPay: number;
  rateIntervalCode: string;
  applicationCloseDate: string;
}[];
interface JobsProps {
  jobs?: Job;
  agencyName?: string;
  query: string;
  affiliate: string;
  vertical: string;
}

const numberToCurrency = new Intl.NumberFormat('en-US', {
  style: 'currency',
  currency: 'USD'
});

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  .jobs-title-wrapper-label {
    color: ${(props) => props.styles.sectionTitleColor};
  }
`;

const showSalary = (job: { minimumPay: number, maximumPay: number, rateIntervalCode: string }) => {
  if (job.minimumPay === null || job.minimumPay === 0 || job.rateIntervalCode === 'Without Compensation') {
    return false;
  }
  return true;
};

const formatSalary = (job: { minimumPay: number, maximumPay: number, rateIntervalCode: string }) => {
  const max    = job.maximumPay;
  const maxStr = numberToCurrency.format(job.maximumPay);
  const minStr = numberToCurrency.format(job.minimumPay);
  const withMax = max > job.minimumPay ? `-${maxStr} `: ' ';
  if (job.rateIntervalCode === 'Per Year' || job.rateIntervalCode === 'Per Hour') {
    const period = job.rateIntervalCode === 'Per Year' ? 'yr' : 'hr';
    const plus   = max > job.minimumPay ? '+' : '';
    return `${minStr}${plus}/${period}`;
  }
  return minStr + withMax + job.rateIntervalCode;
};

export const Jobs = ({ jobs=[], agencyName, query, affiliate, vertical }: JobsProps) => {
  const i18n    = useContext(LanguageContext);
  const styles  = useContext(StyleContext);
  const module  = moduleCode.jobs;

  const { getCollapseProps, getToggleProps, isExpanded } = useCollapse();
  const MAX_JOBS_IN_COLLAPSE_VIEW = 3;
  let lessJobs = jobs;
  let moreJobs:Job = [];

  if (jobs?.length > MAX_JOBS_IN_COLLAPSE_VIEW) {
    lessJobs = jobs.slice(0, MAX_JOBS_IN_COLLAPSE_VIEW);
    moreJobs = jobs.slice(MAX_JOBS_IN_COLLAPSE_VIEW, jobs.length);
  }   

  const jobOpeningsHeader = (agency: string | undefined) => {
    if (agency) {
      return `${i18n.t('jobOpenings')} ${i18n.t('atAgency', { agency })}`;
    }
    return i18n.t('federalJobOpenings');
  };

  return (
    <>
      <StyledWrapper styles={styles}>
        <div className='search-item-wrapper search-jobs-item-wrapper'>
          <GridContainer className='jobs-title-wrapper'>
            <Grid row gap="md">
              <Grid col={true}>
                <h2 className='jobs-title-wrapper-label'>
                  {jobOpeningsHeader(agencyName)}
                </h2>
              </Grid>
              <Grid col={true} className='jobs-logo-wrapper'>
                <a className="usajobs-logo" href="https://www.usajobs.gov/">
                  <img alt="USAJobs.gov" src={usajobsImage} />
                </a>
              </Grid>
            </Grid>
          </GridContainer>
          
          {jobs?.length > 0 ? <>
            {lessJobs?.map((job, index) => {
              return (
                <GridContainer className='result search-result-item' key={index}>
                  <ResultGridWrapper
                    url={job.positionUri}
                    clickTracking={() => clickTracking(affiliate, module, query, index+1, job.positionUri, vertical)}>
                    <Grid col={true} className='result-meta-data'>
                      <div className='result-title'>
                        <h2 className='result-title-label'>
                          <ResultTitle 
                            url={job.positionUri}
                            className='result-title-link'
                            clickTracking={() => clickTracking(affiliate, module, query, index+1, job.positionUri, vertical)}>
                            {job.positionTitle}
                          </ResultTitle>
                        </h2>
                      </div>
                      <div className='result-desc'>
                        <p>{job.organizationName}</p>
                        <ul className="list-horizontal">
                          <li>{job.positionLocation}</li>
                          {showSalary(job) && (<li>{formatSalary(job)}</li>)}
                          <li>Apply by {job.applicationCloseDate}</li>
                        </ul>
                      </div>
                    </Grid>
                  </ResultGridWrapper>
                  <Grid row className="row-mobile-divider"></Grid>
                </GridContainer>
              );
            })}

            {moreJobs?.length > 0 && (<>
              <div {...getCollapseProps()} className='collapsed-jobs-wrapper'>
                {moreJobs?.map((job, index) => {
                  return (
                    <GridContainer className='result search-result-item' key={index}>
                      <ResultGridWrapper
                        url={job.positionUri}
                        clickTracking={() => clickTracking(affiliate, module, query, MAX_JOBS_IN_COLLAPSE_VIEW+index+1, job.positionUri, vertical)}>
                        <Grid col={true} className='result-meta-data'>
                          <div className='result-title'>
                            <h2 className='result-title-label'>
                              <ResultTitle 
                                url={job.positionUri}
                                className='result-title-link'
                                clickTracking={() => clickTracking(affiliate, module, query, MAX_JOBS_IN_COLLAPSE_VIEW+index+1, job.positionUri, vertical)}>
                                {job.positionTitle}
                              </ResultTitle>
                            </h2>
                          </div>
                          <div className='result-desc'>
                            <p>{job.organizationName}</p>
                            <ul className="list-horizontal">
                              <li>{job.positionLocation}</li>
                              {showSalary(job) && (<li>{formatSalary(job)}</li>)}
                              <li>Apply by {job.applicationCloseDate}</li>
                            </ul>
                          </div>
                        </Grid>
                      </ResultGridWrapper>

                      <Grid row className="row-mobile-divider"></Grid>
                    </GridContainer>
                  );
                })}
              </div>
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
            </>)}
          </>: <NoResults errorMsg={i18n.t('noJobResults')} />
          }

          <GridContainer className='result search-result-item'>
            <Grid row gap="md">
              <Grid col={true} className='result-meta-data'>
                <div className='result-title'>
                  <h2 className='result-title-label'>
                    <ResultTitle 
                      url='https://www.usajobs.gov/Search/Results?hp=public'
                      className='result-title-link more-title-link'
                      clickTracking={() => clickTracking(affiliate, module, query, jobs.length+1, 'https://www.usajobs.gov/Search/Results?hp=public', vertical)}>
                      {i18n.t('searches.moreFederalJobOpenings')}
                    </ResultTitle>
                  </h2>
                </div>
              </Grid>
            </Grid>
          </GridContainer>
          
          <GridContainer className='result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer> 
        </div>
      </StyledWrapper>
    </>
  );
};
