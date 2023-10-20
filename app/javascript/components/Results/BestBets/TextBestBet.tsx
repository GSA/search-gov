import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

interface TextBestBetProps {
  title: string;
  url: string;
  description: string;
}

export const TextBestBet = ({ title, url, description }: TextBestBetProps) => {
  return (
    <GridContainer className='result search-result-item boosted-content'>
      <Grid row gap="md">
        <Grid col={true} className='result-meta-data'>
          <div className='result-title'>
            <a href={url} className='result-title-link'>
              <h2 className='result-title-label'>{parse(title)}</h2>
            </a>
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
