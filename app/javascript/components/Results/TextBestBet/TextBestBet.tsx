import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

interface TextBestBetProps {
  title: string;
  url: string;
  description: string;
  parse(html: string): string | JSX.Element | JSX.Element[]
};

export const TextBestBet = ({ title, url, description, parse }: TextBestBetProps) => {
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
)};