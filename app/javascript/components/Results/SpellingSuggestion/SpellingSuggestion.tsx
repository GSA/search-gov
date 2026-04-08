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

export const SpellingSuggestion = ({ suggested, original, originalQuery, originalUrl, suggestedUrl, suggestedQuery, affiliate, vertical }: SpellingSuggestionProps) => {
  const i18n = useContext(LanguageContext);
  const getUrl = (url: string) => window.location.origin + url;
  const position = 1;
  
  const module = (vertical: string) => {
    // blended, docs: to use the default
    let suggestedQueryModule: string = moduleCode.spellingSuggestionsSearch;
    let originalQueryModule: string = moduleCode.spellingOverridesSearch;

    if (vertical === 'web') {
      suggestedQueryModule = moduleCode.spellingSuggestionsBing;
      originalQueryModule = moduleCode.spellingOverridesBing;
    } else if (vertical === 'i14y') {
      originalQueryModule = moduleCode.spellingOverridesI14y;
    } else if (vertical === 'image') {
      suggestedQueryModule = moduleCode.spellingSuggestionsImages;
    }

    return {
      suggestedQueryModule,
      originalQueryModule
    };
  };

  useEffect(() => {
    // Corrected: Clicking on the corrected/suggested query ("Showing results for <correctly spelled query>"):
    if (document.getElementsByClassName('suggestedQuery').length > 0) {
      document.getElementsByClassName('suggestedQuery')[0].addEventListener('click', () => {
        clickTracking(affiliate, module(vertical).suggestedQueryModule, suggestedQuery, position, getUrl(suggestedUrl), vertical);
      });
    }

    // Override: Clicking on the original query ("Search instead for <misspelled query>"):
    if (document.getElementsByClassName('originalQuery').length > 0) {
      document.getElementsByClassName('originalQuery')[0].addEventListener('click', () => {
        clickTracking(affiliate, module(vertical).originalQueryModule, originalQuery, position, getUrl(originalUrl), vertical);
      });
    }
  }, []);

  return (
    <div className='search-result-item-wrapper'>
      <GridContainer className='result search-result-item'>
        <Grid row>
          <Grid tablet={{ col: true }}>
            <div className='spelling-suggestion-wrapper'>
              <div>
                {parse(i18n.t('showingResultsForMsg', { original_query: originalQuery, corrected_query: suggested }))}
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
