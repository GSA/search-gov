import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';

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
  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && (additionalResults.textBestBets?.length > 0 || additionalResults.graphicsBestBet) && (
          <GridContainer className="results-best-bets-wrapper">
            <Grid row gap="md" id="best-bets">
              <Grid col={true}>
                <GridContainer className='best-bets-title'>
                  Recommended by {additionalResults.recommendedBy}
                </GridContainer>
                {additionalResults.textBestBets?.map((textBestBet, index) => {
                  return (
                    <GridContainer key={index} className='result search-result-item boosted-content'>
                      <Grid row gap="md">
                        <Grid col={true} className='result-meta-data'>
                          <div className='result-title'>
                            <a href={textBestBet.url} className='result-title-link'>
                              <h2 className='result-title-label'>{parse(textBestBet.title)}</h2>
                            </a>
                          </div>
                          <div className='result-desc'>
                            <p>{parse(textBestBet.description)}</p>
                            <div className='result-url-text'>{textBestBet.url}</div>
                          </div>
                        </Grid>
                      </Grid>
                    </GridContainer>
                  );
                })}
                {additionalResults.graphicsBestBet && (
                <GridContainer className='result search-result-item graphics-best-bets'>
                  <Grid row gap="md">
                    <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                      <img src={additionalResults.graphicsBestBet.imageUrl} className="result-image"/>
                    </Grid>
                    <Grid col={true} className='result-meta-data'>
                      <div className='graphics-best-bets-title'>
                        {parse(additionalResults.graphicsBestBet.title)}
                      </div>
                      <Grid row gap="md">
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>USAJOBS - Federal Government Jobs</a>
                        </Grid>
                        <Grid mobileLg={{ col: 5 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Veterans Employment</a>
                        </Grid>
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Jobs in Your State</a>
                        </Grid>
                        <Grid mobileLg={{ col: 5 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Disability Resources</a>
                        </Grid>
                        <Grid mobileLg={{ col: 7 }} className='graphics-best-bets-link-wrapper'>
                          <a href='#'>Federal Jobs for Recent Graduates</a>
                        </Grid>
                      </Grid>
                    </Grid>
                  </Grid>
                </GridContainer>)}
              </Grid>
            </Grid>
          </GridContainer>)}

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
