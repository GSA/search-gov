import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import './NoResults.css';

interface NoResultsProps {
  errorMsg?: string
}

export const NoResults = ({ errorMsg = '' }: NoResultsProps) => {
  return (
    <GridContainer className='result search-result-item'>
      <Grid row>
        <Grid tablet={{ col: true }}>
          <div className='no-result-error'>
            {errorMsg}
          </div>
          {/* To do: dynamic */}
          {/* https://github.com/GSA/search-gov/blob/main/app/views/searches/_no_results.html.haml */}
          <div className='additional-guidance-text'>
            Are you looking for information from across government? Please search again on USA.gov. Click the "Search again on USA.gov" link above the search button here, or use the link below to go to the main USA.gov website. Search.gov is a service powering the search boxes on government agencies' websites. You are currently searching the Search.gov website, and this website only contains information about our service.
          </div>
          <div className='search-tips'>
            <div className='search-tips-label'>Search Tips</div>
            {/* To do: dynamic */}
            <div className='no-results-pages-alt-links'>
              <ul>
                <li>Check your search for typos</li>
                <li>Use more generic search terms</li>
                <li><a href="https://usa.gov">USA.gov</a></li>
              </ul>
            </div>
          </div>
        </Grid>
      </Grid>
    </GridContainer>
  );
};
