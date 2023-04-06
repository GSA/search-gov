import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { Pagination } from './../Pagination/Pagination';
interface ResultsProps {
  results: {
    title: string,
    unescapedUrl: string,
    thumbnail: {
      url: string
    },
    content: string
  }[];
  vertical: string;
}

export const Results = (props: ResultsProps) => {
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
                    <Grid tablet={{ col: true }}><a href= "#">{result.unescapedUrl}</a></Grid>
                  </Grid>
                  {props.vertical === 'image' && <Grid row>
                    <Grid tablet={{ col: true }}><img src={result.thumbnail.url} className="result-image"/></Grid>
                  </Grid>}
                  <Grid row>
                    <Grid tablet={{ col: true }}><p>{result.content}</p></Grid>
                  </Grid>
                </GridContainer>
              </div>
            );
          })}
        </div>
      </div>
      {props.results.length > 0 && 
        <Pagination 
          totalPages={props.results.length}
          pathname={window.location.href}
        />
      }
    </>
  );
};
