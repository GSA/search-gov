import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import './ResultsCount.css';

interface ResultsCountProps {
  total: number;
}

export const ResultsCount = ({ total }: ResultsCountProps) => {  
  return (
    <div className='results-count-wrapper search-result-item-wrapper'>
      <GridContainer className='search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='results-count'>
            {total} results
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
