import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import './NoResults.css';

interface NoResultsProps {
  errorMsg?: string;
  noResultsMessage?: {
    text?: string;
    urls?: {
      title: string;
      url: string;
    }[];
  };
}

export const NoResults = ({ errorMsg = '', noResultsMessage }: NoResultsProps) => {
  return (
    <GridContainer className='result search-result-item'>
      <Grid row>
        <Grid tablet={{ col: true }}>
          <div className='no-result-error'>
            {errorMsg}
          </div>
          {noResultsMessage?.text &&
            <div className='additional-guidance-text'>
              {noResultsMessage.text}
            </div>
          }
          {noResultsMessage?.urls &&
            <div className='search-tips'>
              <div className='no-results-pages-alt-links'>
                <ul>
                  {noResultsMessage.urls.map((url, index) => {
                    if (url.url) {
                      return <li key={index}><a href={url.url}>{url.title}</a></li>
                    } else {
                      return <li key={index}>{url.title}</li>
                    }
                  })}
                </ul>
              </div>
            </div>
          }
        </Grid>
      </Grid>
    </GridContainer>
  );
};
