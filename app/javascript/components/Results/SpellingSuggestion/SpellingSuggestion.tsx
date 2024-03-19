/* eslint-disable camelcase */
import React, { useContext, useEffect } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultTitle from '../../Results/ResultGrid/ResultTitle';

import './SpellingSuggestion.css';

interface SpellingSuggestionProps {
  suggested: string;
  original: string;
  originalUrl: string;
  originalQuery: string;
  suggestedQuery: string;
  suggestedUrl: string;
}

export const SpellingSuggestion = ({ suggested, original, originalQuery, originalUrl, suggestedUrl, suggestedQuery  }: SpellingSuggestionProps) => {
  const i18n = useContext(LanguageContext);
  
  useEffect(() => {
    document.getElementsByClassName('suggestedQuery')[0].addEventListener("click", function(){
      clickTracking("affiliate", "module", suggestedQuery, 1, suggestedUrl, "vertical")
    });

    document.getElementsByClassName('originalQuery')[0].addEventListener("click", function(){
      clickTracking("affiliate", "module", originalQuery, 1, originalUrl, "vertical")
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

                {/* <ResultTitle 
                  url={originalUrl}
                  clickTracking={() => clickTracking("affiliate", "module", "query", 0, "result.url", "vertical")}>
                    {originalQuery}
                </ResultTitle> */}
              </div>
            </div>
          </Grid>
        </Grid>
      </GridContainer>
    </div>
  );
};
