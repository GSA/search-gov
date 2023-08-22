import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';

import './NoResults.css';

interface NoResultsProps {
  errorMsg?: string
}

export const NoResults = ({ errorMsg = '' }: NoResultsProps) => {
  const i18n = useContext(LanguageContext);

  return (
    <GridContainer className='result search-result-item'>
      <Grid row>
        <Grid tablet={{ col: true }}>
          <div className='no-result-error'>
            {errorMsg}
          </div>
          {/* To do: dynamic */}
          {/* https://github.com/GSA/search-gov/blob/main/app/views/searches/_no_results.html.haml */}
          <div className='additional-guidance-text'>{i18n.t('additionalGuidance')}</div>
          <div className='search-tips'>
            <div className='search-tips-label'>{i18n.t('searchTipsTitle')}</div>
            {/* To do: dynamic */}
            <div className='no-results-pages-alt-links'>
              <ul>
                <li>{i18n.t('searchTip1')}</li>
                <li>{i18n.t('searchTip2')}</li>
                <li><a href="https://usa.gov">USA.gov</a></li>
              </ul>
            </div>
          </div>
        </Grid>
      </Grid>
    </GridContainer>
  );
};
