import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

export const FedRegister = () => {
  return (
    <div className='search-item-wrapper fed-register-item-wrapper'>
      <GridContainer className='fed-register-wrapper'>
        <Grid row gap="md">
          <h2 className='fed-register-label'>
            Federal Register documents about Benefits
          </h2>
        </Grid>
      </GridContainer>
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>May 11, 2011</span>
            
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Unsuccessful Work Attempts and Expedited Reinstatement
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>A Proposed Rule by the Social Security Administration</p>
              <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
              <div className='comment-period'>Comment period ends July 6, 2023</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>May 11, 2016</span>
            
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Unsuccessful Work Attempts and Expedited Reinstatement Eligibility
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>A Proposed Rule by the Social Security Administration</p>
              <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
              <div className='comment-period-ended'>Comment period has ended</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>July 29, 2013.</span>
            
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Mailing of Tickets Under the Ticket To Work Program
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>A Rule by the Department of Veterans Affairs, the Office of Personnel Management, the Railroad Retirement Board, the Social Security Administration and the Treasury Department</p>
              <div className='pages-count'>Pages 29212 - 29215 (4 pages) [FR DOC #: 2016-10932]</div>
              <div className='comment-period-ended'>Comment period has ended</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <div className='result-title'>
              <a href="" className='more-fed-register-link'>
                More SSA documents on FederalRegister.gov
              </a>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>

      <GridContainer className='result-divider'>
        <Grid row gap="md">
        </Grid>
      </GridContainer>
    </div>
  );
};
