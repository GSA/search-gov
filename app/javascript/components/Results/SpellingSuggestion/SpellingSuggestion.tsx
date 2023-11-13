/* eslint-disable camelcase */
import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import parse from 'html-react-parser';

import './SpellingSuggestion.css';

interface SpellingSuggestionProps {
  suggested: string;
  original: string;
}

export const SpellingSuggestion = ({ suggested, original }: SpellingSuggestionProps) => {
  const i18n = useContext(LanguageContext);
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
