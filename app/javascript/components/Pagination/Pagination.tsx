import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { UswdsPagination } from './UswdsPagination';

import './Pagination.css';
interface PaginationProps {
  pathname: string
  totalPages: number
}

const getCurrentPage = (): number => {
  const queryString = window.location.search;
  const urlParams = new URLSearchParams(queryString);
  return Number(urlParams.get('page')) ? Number(urlParams.get('page')) : 1;
};

export const Pagination = (props: PaginationProps) => {
  return (
    <div className="serp-pagination-wrapper">
      <GridContainer>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <UswdsPagination 
              pathname={props.pathname} 
              totalPages={props.totalPages} 
              currentPage={getCurrentPage()} 
            />
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
