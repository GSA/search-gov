import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from '../ResultGrid/ResultGridWrapper';
import ResultTitle from '../ResultGrid/ResultTitle';
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
  const module = (() => {
    return moduleCode.bestBetsText;
  })();

  return (
    <GridContainer className='result search-result-item boosted-content'>
      <ResultGridWrapper
        url={url}
        clickTracking={() => clickTracking(affiliate, module, query, position, url, vertical)}>
        <Grid col={true} className='result-meta-data'>
          <div className='result-title'>
            <h2 className='result-title-label'>
              <ResultTitle 
                url={url}  
                className='result-title-link'
                clickTracking={() => clickTracking(affiliate, module, query, position, url, vertical)}>
                {parse(title)}
              </ResultTitle>
            </h2>
          </div>
          <div className='result-desc'>
            <p>{parse(description)}</p>
            <div className='result-url-text'>{url}</div>
          </div>
        </Grid>
      </ResultGridWrapper>
    </GridContainer>
  );
};
