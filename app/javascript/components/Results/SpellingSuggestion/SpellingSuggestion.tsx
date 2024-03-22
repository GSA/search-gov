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

  const clickTrackingModuleMap = {
    web: {
      suggestedQueryModule: moduleCode.spellingSuggestionsBing,
      originalQueryModule: moduleCode.spellingOverridesBing
    },
    blended: {
      suggestedQueryModule: moduleCode.spellingSuggestionsSearch
    },
    i14y: {
      suggestedQueryModule: moduleCode.spellingSuggestionsSearch,
      originalQueryModule: moduleCode.spellingOverridesI14
    },
    image: {
      suggestedQueryModule: moduleCode.spellingSuggestionsImages
    }
    // UNABLE TO FIND THE MODULE CODE
    // docs: {
      // suggestedQueryModule: ?????,
      // originalQueryModule: ?????
    // }
  }

  const clickTrackingModule = (vertical: string, queryType: string): string => clickTrackingModuleMap[vertical] && clickTrackingModuleMap[vertical][queryType];

  
  useEffect(() => {
    // Corrected: Clicking on the corrected query ("Showing results for <correctly spelled query>"):
    if(clickTrackingModule(vertical, 'suggestedQueryModule')){
      document.getElementsByClassName('suggestedQuery')[0].addEventListener('click', () => {
        clickTracking(affiliate, clickTrackingModule(vertical, 'suggestedQueryModule'), suggestedQuery, position, getUrl(suggestedUrl), vertical);
      });
    }

    // Override: Clicking on the original query ("Search instead for <misspelled query>"):
    if(clickTrackingModule(vertical, 'originalQueryModule')){
      document.getElementsByClassName('originalQuery')[0].addEventListener('click', () => {
        clickTracking(affiliate, clickTrackingModule(vertical, 'originalQueryModule'), originalQuery, position, getUrl(originalUrl), vertical);
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
