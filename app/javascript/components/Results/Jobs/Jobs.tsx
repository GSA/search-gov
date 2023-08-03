import React from 'react';
import { GridContainer, Grid, Icon } from '@trussworks/react-uswds';
import { useCollapse } from 'react-collapsed';

import './Jobs.css';

export const Jobs = () => {
  const { getCollapseProps, getToggleProps, isExpanded } = useCollapse();
  return (
    <div className='search-item-wrapper search-jobs-item-wrapper'>
      <GridContainer className='jobs-title-wrapper'>
        <Grid row gap="md">
          <Grid col={true}>
            <h2 className='jobs-title-wrapper-label'>
              Job Openings at SSA
            </h2>
          </Grid>
          <Grid col={true} className='jobs-logo-wrapper'>
            <a className="usajobs-logo" href="https://www.usajobs.gov/">
              <img alt="USAJobs.gov" src="https://d15vqlr7iz6e8x.cloudfront.net/assets/searches/usajobs-bab6b21076d3a8fdf0808ddbde43f24858db74b226057f19daa10ef3b3fba090.jpg" />
            </a>
          </Grid>
        </Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  SSA HQ (MD/DC/VA) - Accepting Resumes from Individuals with Disabilities
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Federal Aviation Administration</p>
              <ul className="list-horizontal">
                <li>Multiple Locations</li>
                <li>$38,560.00-$123,652.00 PA</li>
                <li>Apply by September 13, 2023</li>
              </ul>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Data Scientist
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Federal Aviation Administration</p>
              <ul className="list-horizontal">
                <li>Multiple Locations</li>
                <li>$98,496.00-$128,043.00 PA</li>
                <li>Apply by September 20, 2023</li>
              </ul>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Accountant
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Federal Aviation Administration</p>
              <ul className="list-horizontal">
                <li>Multiple Locations</li>
                <li>$48,560.00-$125,652.00 PA</li>
                <li>Apply by August 20, 2023</li>
              </ul>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <div {...getCollapseProps()} className='collapsed-jobs-wrapper'>
        <GridContainer className='result search-result-item'>
          <Grid row gap="md">
            <Grid col={true} className='result-meta-data'>
              <div className='result-title'>
                <a href="" className='result-title-link'>
                  <h2 className='result-title-label'>
                    Legal Administrative Specialist (Benefit Authorizer) - Direct Hire
                  </h2>
                </a>
              </div>
              <div className='result-desc'>
                <p>Federal Aviation Administration</p>
                <ul className="list-horizontal">
                  <li>Multiple Locations</li>
                  <li>$58,560.00-$123,652.00 PA</li>
                  <li>Apply by September 25, 2023</li>
                </ul>
              </div>
            </Grid>
          </Grid>
          <Grid row className="row-mobile-divider"></Grid>
        </GridContainer>

        <GridContainer className='result search-result-item'>
          <Grid row gap="md">
            <Grid col={true} className='result-meta-data'>
              <div className='result-title'>
                <a href="" className='result-title-link'>
                  <h2 className='result-title-label'>
                    Data Scientist
                  </h2>
                </a>
              </div>
              <div className='result-desc'>
                <p>Federal Aviation Administration</p>
                <ul className="list-horizontal">
                  <li>Multiple Locations</li>
                  <li>$78,560.00-$150,652.00 PA</li>
                  <li>Apply by October 20, 2023</li>
                </ul>
              </div>
            </Grid>
          </Grid>
          <Grid row className="row-mobile-divider"></Grid>
        </GridContainer>

        <GridContainer className='result search-result-item'>
          <Grid row gap="md">
            <Grid col={true} className='result-meta-data'>
              <div className='result-title'>
                <a href="" className='result-title-link'>
                  <h2 className='result-title-label'>
                    SSA HQ (MD/DC/VA) - Accepting Resumes from Individuals with Disabilities
                  </h2>
                </a>
              </div>
              <div className='result-desc'>
                <p>Federal Aviation Administration</p>
                <ul className="list-horizontal">
                  <li>Multiple Locations</li>
                  <li>$38,560.00-$123,652.00 PA</li>
                  <li>Apply by September 13, 2023</li>
                </ul>
              </div>
            </Grid>
          </Grid>
          <Grid row className="row-mobile-divider"></Grid>
        </GridContainer>
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
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <div className='result-title'>
              <a href="" className='result-title-link more-jobs-title-link'>
                <h2 className='result-title-label'>
                  Go to USAJobs.gov to see more openings
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
  );
};
