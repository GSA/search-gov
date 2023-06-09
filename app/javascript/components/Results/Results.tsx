import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';

import './Results.css';

interface ResultsProps {
  query?: string
  results?: {
    title: string,
    url: string,
    thumbnail?: {
      url: string
    },
    description: string,
    updatedDate?: string,
    publishedDate?: string,
    thumbnailUrl?: string
  }[] | null;
  additionalResults?: {
    recommendedBy: string;
    textBestBets?: {
      title: string;
      url: string;
      description: string;
    }[];
    graphicsBestBet?: {
      title: string;
      titleUrl?: string;
      imageUrl?: string;
      imageAltText?: string;
      links?: {
        title: string;
        url: string;
      }[];
    }
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
}

export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical }: ResultsProps) => {
  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && (
          <BestBets
            {...additionalResults}
            parse={parse}
          />
        )}
        <div id="results" className="search-result-item-wrapper">
          {results && results.length > 0 ? (results.map((result, index) => {
            return (
              <GridContainer key={index} className='result search-result-item'>
                <Grid row gap="md">
                  {vertical === 'image' &&
                  <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                    <img src={result.thumbnail?.url} className="result-image" alt={result.title}/>
                  </Grid>
                  }
                  <Grid col={true} className='result-meta-data'>
                    {result.publishedDate && (<span className='published-date'>{result.publishedDate}</span>)}
                    {result.updatedDate && (<span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>)}
                    <div className='result-title'>
                      <a href={result.url} className='result-title-link'>
                        <h2 className='result-title-label'>
                          {result.title} 
                          {/* ToDo: This need to be dynamic */}
                          <span className='filetype-label'>PDF</span>
                        </h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>{result.description}</p>
                      <div className='result-url-text'>{result.url}</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
            );
          })) : (
            <GridContainer className='result search-result-item'>
              <Grid row>
                <Grid tablet={{ col: true }}>
                  <h4>Sorry, no results found for &#39;{query}&#39;. Try entering fewer or more general search terms.</h4>
                </Grid>
              </Grid>
            </GridContainer>)}
        </div>
      </div>
      <Pagination 
        totalPages={totalPages}
        pathname={window.location.href}
        unboundedResults={unboundedResults}
      />
    </>
  );
};
