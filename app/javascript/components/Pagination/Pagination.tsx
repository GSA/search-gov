import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { UswdsPagination } from './UswdsPagination';

import './Pagination.css';

const getCurrentPage = (): number => {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  return Number(urlParams.get('page')) ? Number(urlParams.get('page')) : 1;
};

export const Pagination = ({totalPages, pathname}) => {
  return (
    <div className="serp-pagination-wrapper">
      <GridContainer>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <UswdsPagination 
              pathname={pathname} 
              totalPages={totalPages} 
              currentPage={getCurrentPage()} 
            />
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
