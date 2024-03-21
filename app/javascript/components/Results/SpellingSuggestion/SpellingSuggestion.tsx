/* eslint-disable camelcase */
import React, { useContext, useEffect } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import './SpellingSuggestion.css';
interface SpellingSuggestionProps {
  suggested: string;
  original: string;
  originalUrl: string;
  originalQuery: string;
  suggestedQuery: string;
  suggestedUrl: string;
  affiliate: string;
  vertical: string;
}

export const SpellingSuggestion = ({ suggested, original, originalQuery, originalUrl, suggestedUrl, suggestedQuery, affiliate, vertical  }: SpellingSuggestionProps) => {
  const i18n = useContext(LanguageContext);

  const getUrl = (url: string) => window.location.origin + url;
  
  useEffect(() => {
    document.getElementsByClassName('suggestedQuery')[0].addEventListener('click', () => {
      clickTracking(affiliate, 'BWEB', suggestedQuery, 1, getUrl(suggestedUrl), vertical)
    });

    document.getElementsByClassName('originalQuery')[0].addEventListener('click', () => {
      clickTracking(affiliate, 'BWEB', originalQuery, 1, getUrl(originalUrl), vertical)
    });
  }, []);

  return (
    <div className='search-result-item-wrapper'>
      <GridContainer className='result search-result-item'>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <div className='spelling-suggestion-wrapper'>
              <div>
                {parse(i18n.t('showingResultsFor', { corrected_query: suggested }))}
              </div>
              <div className='spelling-search-instead-for'>
                {parse(i18n.t('searchInsteadFor', { original_query: original }))}
              </div> 
            </div>
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
