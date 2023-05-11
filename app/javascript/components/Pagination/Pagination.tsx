import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { UswdsPagination } from '../UswdsOverrides/UswdsPagination';

import { getCurrentPage } from '../../utils';

import './Pagination.css';
interface PaginationProps {
  pathname: string
  totalPages: number | null
  unboundedResults: boolean
}

export const Pagination = ({ pathname, totalPages = null, unboundedResults }: PaginationProps) => {
  if ((!totalPages || totalPages < 2 || getCurrentPage() > totalPages)) {
    return (<></>);
  }

  return (
    <div className="serp-pagination-wrapper">
      <GridContainer>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <UswdsPagination 
              pathname={pathname} 
              totalPages={totalPages} 
              currentPage={getCurrentPage()}
              unboundedResults={unboundedResults}
            />
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
