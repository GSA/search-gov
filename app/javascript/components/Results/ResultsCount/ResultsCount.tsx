/* eslint-disable camelcase */
import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { numberWithDelimiter } from '../../../utils';

import './ResultsCount.css';

interface ResultsCountProps {
  total: number;
}

export const ResultsCount = ({ total }: ResultsCountProps) => {  
  const i18n = useContext(LanguageContext);

  return (
    <div className='results-count-wrapper search-result-item-wrapper'>
      <GridContainer className='search-result-item'>
        <Grid row gap="md">
          <Grid col={true} className='results-count'>
            {i18n.t('searches.resultsCount', { count: total, formatted_count: numberWithDelimiter(total) })}
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
