import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
interface ResultsProps {
  results: {}[]
  vertical: string
}

export const Results = (props: ResultsProps) => {
  return (
    <div id="serp-results-wrapper">
      <div id="results">
        {props.results.map((result, index) => {
          return (
            <div className='result' key={index}>
              <GridContainer>
                <Grid row>
                  <Grid tablet={{ col: true }}><a href= "#" ><h4>{result['title']}</h4></a></Grid>
                </Grid>
                <Grid row>
                  <Grid tablet={{ col: true }}><a href= "#">{result['unescapedUrl']}</a></Grid>
                </Grid>
                {props.vertical === 'image' && <Grid row>
                  <Grid tablet={{ col: true }}><img src={result['thumbnail']['url']} className="result-image"/></Grid>
                </Grid>}
                <Grid row>
                  <Grid tablet={{ col: true }}><p>{result['content']}</p></Grid>
                </Grid>
              </GridContainer>
            </div>
            )
          }
        )}
      </div>
    </div>
  );
}
