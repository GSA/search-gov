import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { Pagination } from './../Pagination/Pagination';

import './Results.css';
interface ResultsProps {
  results: {
    title: string,
    url: string,
    thumbnail: {
      url: string
    },
    description: string
  }[];
  vertical: string;
}

export const Results = (props: ResultsProps) => {
  const totalPages = 10; // to do: updated once we get pagination data from the backend
  
  return (
    <>
      <div className='search-result-wrapper'>
        {/* ToDo: This need to be dynamic: this is for UI purposes only */}
        <GridContainer className="results-best-bets-wrapper">
          <Grid row gap="md">
            <Grid col={true}>
              <GridContainer className='best-bets-title'>
                Recommended by GSA
              </GridContainer>
              <GridContainer className='result search-result-item'>
                <Grid row gap="md">
                  <Grid col={true} className='result-meta-data'>
                    {/* ToDo: This date need to be dynamic */}
                    <div className='published-date'>
                      July 4th, 2022
                    </div>
                    <div className='result-title'>
                      <a href="https://search.gov/" className='result-title-link'>
                        <h2 className='result-title-label'>Gears of Government President’s Award winners</h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>Today, the Administration announces the winners of the Gears of Government President’s Award. This program recognizes the contributions of individuals and teams across the federal workforce who make a profound difference in the lives of the American people.</p>
                      <div className='result-url-text'>https://search.gov/</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
              <GridContainer className='result search-result-item'>
                <Grid row gap="md">
                  <Grid col={true} className='result-meta-data'>
                    {/* This date need to be dynamic */}
                    <div className='published-date'>
                      July 4th, 2022
                    </div>
                    <div className='result-title'>
                      <a href="https://search.gov/" className='result-title-link'>
                        <h2 className='result-title-label'>Gears of Government President’s Award winners</h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>Today, the Administration announces the winners of the Gears of Government President’s Award. This program recognizes the contributions of individuals and teams across the federal workforce who make a profound difference in the lives of the American people.</p>
                      <div className='result-url-text'>https://search.gov/</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
              <GridContainer className='result search-result-item graphics-best-bets'>
                <Grid row gap="md">
                  <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                    <img src="https://plus.unsplash.com/premium_photo-1666277012069-bd342b857f89?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=300&q=10" className="result-image"/>
                  </Grid>
                  <Grid col={true} className='result-meta-data'>
                    {/* ToDo: This need to be dynamic */}
                    <div className='graphics-best-bets-title'>
                      Find a Job
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
              </GridContainer>
            </Grid>
          </Grid>
        </GridContainer>

        <div id="results" className="search-result-item-wrapper">
          {props.results.map((result, index) => {
            return (
              <GridContainer key={index} className='result search-result-item'>
                <Grid row gap="md">
                  { props.vertical === 'image' &&
                  <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                    <img src={result.thumbnail.url} className="result-image"/>
                  </Grid>
                  }
                  <Grid col={true} className='result-meta-data'>
                    {/* ToDo: This date need to be dynamic */}
                    <div className='published-date'>
                      July 4th, 2022 <span>&#40;Updated on July 10th, 2022&#41;</span>
                    </div>
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
          })}
        </div>
      </div>
      {totalPages > 0 && 
        <Pagination 
          totalPages={totalPages}
          pathname={window.location.href}
        />
      }
    </>
  );
};
