import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from '../ResultGrid/ResultGridWrapper';
import ResultTitle from '../ResultGrid/ResultTitle';
import { LanguageContext } from '../../../contexts/LanguageContext';

type RelatedSearch = {
  label: string; 
  link: string;
};

interface RelatedSearchesProps {
  affiliate: string;
  relatedSearches?: RelatedSearch[];
  query: string;
  vertical: string;
}

export const RelatedSearches = ({ affiliate, relatedSearches=[], query, vertical }: RelatedSearchesProps) => {
  const i18n = useContext(LanguageContext);

  const module = moduleCode.relatedSearches;

  return (
    <>
      {relatedSearches?.length > 0 && (
        <div className='search-item-wrapper related-searches-item-wrapper'>
          <GridContainer className='related-searches-wrapper'>
            <Grid row gap="md">
              <h2 className='related-searches-label'>
                {i18n.t('relatedSearches')}
              </h2>
            </Grid>
          </GridContainer>
          
          {relatedSearches?.map((relatedSearch, index) => {
            return (
              <GridContainer className='result search-result-item' key={index}>
                <ResultGridWrapper
                  url={relatedSearch.link}
                  clickTracking={() => clickTracking(affiliate, module, query, index+1, `${window.location.origin}${relatedSearch.link}`, vertical)}>
                  <Grid col={true} className='result-meta-data'>
                    <div className='result-title'>
                      <h2 className='result-title-label'>
                        <ResultTitle 
                          url={relatedSearch.link}
                          className='result-title-link'>
                          {parse(relatedSearch.label)}
                        </ResultTitle>
                      </h2>
                    </div>
                  </Grid>
                </ResultGridWrapper>
              </GridContainer>
            );
          })}

          <GridContainer className='result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer>
        </div>
      )}
    </>
  );
};
