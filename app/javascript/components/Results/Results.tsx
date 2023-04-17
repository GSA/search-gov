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
        <div id="results">
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
