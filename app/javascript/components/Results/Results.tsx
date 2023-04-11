import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { Pagination } from './../Pagination/Pagination';
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
      <div id="serp-results-wrapper">
        <div id="results">
          {props.results.map((result, index) => {
            return (
              <div className='result' key={index}>
                <GridContainer>
                  <Grid row>
                    <Grid tablet={{ col: true }}><a href= "#" ><h4>{result.title}</h4></a></Grid>
                  </Grid>
                  <Grid row>
                    <Grid tablet={{ col: true }}><a href= "#">{result.url}</a></Grid>
                  </Grid>
                  {props.vertical === 'image' && <Grid row>
                    <Grid tablet={{ col: true }}><img src={result.thumbnail.url} className="result-image"/></Grid>
                  </Grid>}
                  <Grid row>
                    <Grid tablet={{ col: true }}><p>{result.description}</p></Grid>
                  </Grid>
                </GridContainer>
              </div>
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
