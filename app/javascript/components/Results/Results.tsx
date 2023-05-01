import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { Pagination } from './../Pagination/Pagination';

import './Results.css';
interface ResultsProps {
  results: {
    title: string,
    url: string,
    thumbnail?: {
      url: string
    },
    description: string,
    updatedDate: string,
    publishedDate: string,
    thumbnailUrl: string
  }[];
  unboundedResults: boolean;
  totalPages: number;
  vertical: string;
}

export const Results = (props: ResultsProps) => {
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
                    <div className='result-title'>
                      <a href="https://medlineplus.gov/appendixb.html" className='result-title-link'>
                        <h2 className='result-title-label'>Appendix B: Some Common Abbreviations - MedlinePlus</h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>ABG. Arterial blood gases. You may have an ABG test to detect lung diseases. ACE. Angiotensin converting enzyme. Drugs called ACE inhibitors are used to treat high blood pressure, heart failure, diabetes and kidney diseases. ACL. Anterior cruciate ligament. Commonly injured part of the knee.</p>
                      <div className='result-url-text'>https://medlineplus.gov/appendixb.html</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
              <GridContainer className='result search-result-item'>
                <Grid row gap="md">
                  <Grid col={true} className='result-meta-data'>
                    {/* This date need to be dynamic */}
                    <div className='result-title'>
                      <a href="https://clinicaltrials.gov/ct2/search/index" className='result-title-link'>
                        <h2 className='result-title-label'>Find Studies - ClinicalTrials.gov</h2>
                      </a>
                    </div>
                    <div className='result-desc'>
                      <p>Learn how to find studies that have been updated with study results, including studies with results that have been published in medical journals. How to Read a Study Record. Learn about the information available in a study record and the different ways to view a record.</p>
                      <div className='result-url-text'>https://clinicaltrials.gov/ct2/search/index</div>
                    </div>
                  </Grid>
                </Grid>
              </GridContainer>
              <GridContainer className='result search-result-item graphics-best-bets display-none'>
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
          })}
        </div>
      </div>
      {props.totalPages > 1 && 
        <Pagination 
          totalPages={props.totalPages}
          pathname={window.location.href}
          unboundedResults={props.unboundedResults}
        />
      }
    </>
  );
};
