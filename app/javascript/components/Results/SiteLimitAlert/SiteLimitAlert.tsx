/* eslint-disable camelcase */
import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';

import './SiteLimitAlert.css';

// HTML escape function to prevent XSS
const escapeHtml = (text: string): string => {
  const div = document.createElement('div');
  div.textContent = text;
  return div.innerHTML;
};

interface SiteLimitAlertProps {
  sitelimit: string;
  url: string;
  query: string
}

export const SiteLimitAlert = ({ sitelimit, url, query }: SiteLimitAlertProps) => {
  const i18n = useContext(LanguageContext);

  const createSafeQueryLink = () => {
    const escapedQuery = escapeHtml(query);
    const linkText = i18n.t('searches.siteLimits.queryFromAllSites', { query: escapedQuery });
    return `<a class='usa-link' href='${url}'>${linkText}</a>`;
  };

  return (
    <div className='search-result-item-wrapper'>
      <GridContainer className='result search-result-item'>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <div className='sitelimit-alert-wrapper'>
              <div>
                {i18n.t('searches.siteLimits.includingResultsForQueryFromMatchingSites', { query, matching_sites: sitelimit })}
              </div>
              <div className='sitelimit-search-instead-for'>
                { parse(i18n.t('searches.siteLimits.doYouWantToSeeResultsFor', { query_from_all_sites: createSafeQueryLink() })) }
              </div>
            </div>
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
