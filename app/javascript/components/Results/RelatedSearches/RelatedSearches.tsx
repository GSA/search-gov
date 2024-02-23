import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { LanguageContext } from '../../../contexts/LanguageContext';

type RelatedSearch = {
  label: string; 
  link: string;
};

interface RelatedSearchesProps {
  relatedSearches?: RelatedSearch[];
}

export const RelatedSearches = ({ relatedSearches=[] }: RelatedSearchesProps) => {
  const i18n = useContext(LanguageContext);

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
                <Grid row gap="md">
                  <Grid col={true} className='result-meta-data'>
                    <div className='result-title'>
                      <h2 className='result-title-label'>
                        <a href={relatedSearch.link} className='result-title-link'>
                          {parse(relatedSearch.label)}
                        </a>
                      </h2>
                    </div>
                  </Grid>
                </Grid>
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
