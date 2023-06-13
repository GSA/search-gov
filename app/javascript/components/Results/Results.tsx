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
    textBestBets: {
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
  const imagesToBeDynamic = [
    {
      url: 'https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 1'
    },
    {
      url: 'https://images.unsplash.com/flagged/photo-1552483570-019b7f8119b2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 2'
    },
    {
      url: 'https://images.unsplash.com/photo-1446776877081-d282a0f896e2?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 3'
    },
    {
      url: 'https://images.unsplash.com/photo-1502134249126-9f3755a50d78?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8bmFzYXxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 4'
    },
    {
      url: 'https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60',
      title: 'title 5'
    }
  ];

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
          {/* Below images to be dynamic - To Do as part of backend integration */}
          <GridContainer className='result search-result-item search-result-image-item'>
            <Grid row gap="md">
              {(imagesToBeDynamic.map((image, index) => {
                return (
                  <Grid key={index} mobileLg={{ col: 4 }} className='result-thumbnail margin-bottom-4'>
                    <img src={image.url} className="result-image" alt={image.title} />
                  </Grid>
                );
              }))}
            </Grid>
          </GridContainer>

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
