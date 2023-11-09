/* eslint-disable camelcase */
import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';

import './SiteLimitAlert.css';

interface SiteLimitAlertProps {
  sitelimit: string;
  url: string;
  query: string
}

export const SiteLimitAlert = ({ sitelimit, url, query }: SiteLimitAlertProps) => {
  const i18n = useContext(LanguageContext);

  const query_from_all_sites = () => {
    return `<a class='usa-link' href=${url}>${i18n.t('searches.siteLimits.queryFromAllSites', {query: query})}</a>`
  }

  return (
    <div className='search-result-item-wrapper'>
      <GridContainer className='result search-result-item'>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <div className='spelling-suggestion-wrapper'>
              <div>
                {i18n.t('searches.siteLimits.includingResultsForQueryFromMatchingSites', {query: query, matching_sites: sitelimit})}
              </div>
              <div className='spelling-search-instead-for'>
                {
                  parse(
                    i18n.t('searches.siteLimits.doYouWantToSeeResultsFor', {
                        query_from_all_sites: query_from_all_sites()
                      }
                    )
                  )
                }
              </div>
            </div>
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
