import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { UswdsPagination } from '../UswdsOverrides/UswdsPagination';

import { getCurrentPage } from '../../utils';

import './Pagination.css';
interface PaginationProps {
  pathname: string
  totalPages: number
}

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
