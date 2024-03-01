import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import ResultTitle from '../ResultGrid/ResultTitle';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';

interface TextBestBetProps {
  affiliate: string;
  title: string;
  url: string;
  description: string;
  position: number;
  query: string;
  vertical: string;
}

export const TextBestBet = ({ affiliate, title, url, description, position, query, vertical }: TextBestBetProps) => {
  return (
    <GridContainer className='result search-result-item boosted-content'>
      <Grid row gap="md">
        <Grid col={true} className='result-meta-data'>
          <div className='result-title'>
            <h2 className='result-title-label'>
              <ResultTitle 
                url={url}  
                className='result-title-link'
                clickTracking={() => clickTracking(affiliate, moduleCode.bestBetsText, query, position, url, vertical)}>
                {parse(title)}
              </ResultTitle>
            </h2>
          </div>
          <div className='result-desc'>
            <p>{parse(description)}</p>
            <div className='result-url-text'>{url}</div>
          </div>
        </Grid>
      </Grid>
    </GridContainer>
  );
};
