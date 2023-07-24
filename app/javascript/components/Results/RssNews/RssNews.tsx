import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

export const RssNews = () => {
  return (
    <div className='search-item-wrapper search-news-item-wrapper'>
      <GridContainer className='news-title-wrapper'>
        <Grid row gap="md">
          <h2 className='news-title-wrapper-label'>
            News about Benefits
          </h2>
        </Grid>
      </GridContainer>
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>1 hr</span>
            
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Benefit eligibility for married same-sex couples
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, potential eligibility for benefits by survivors ullamco laboris nisi ut aliquip ex ea commodo consequat...</p>
              <div className='result-url-text'>https://www.news.com</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>
      
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>17 hrs ago</span>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Benefits Planner: Retirement | Benefits For Your Family | SSA
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Find out your full retirement age, which is when you become eligible for unreduced Social Security retirement benefits. The year and month you reach full retirement age depends on the year you were born.</p>
              <div className='result-url-text'>https://www.news.com</div>
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
