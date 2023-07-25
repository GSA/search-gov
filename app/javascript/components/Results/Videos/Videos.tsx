import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

export const Videos = () => {
  return (
    <div className='search-item-wrapper'>
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
            <img src='https://images.unsplash.com/photo-1603398938378-e54eab446dde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8bWVkaWNhbHxlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60' className="result-image" alt="image title"/>
            <div className="video-duration">
              <div className="tri-icon"></div>
              <span>42:02</span>
            </div>
          </Grid>
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>About 1 month ago</span>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Violent Tornado Animation of an EF5 Supercell
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Watch search.gov’s training video on how to get the search right on your site.</p>
              <div className='result-url-text'>https://youtube.com/Ed4%53Wt/searchtraining</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>
      <GridContainer className='result search-result-item'>
        <Grid row gap="md">
          <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
            <img src='https://plus.unsplash.com/premium_photo-1664303499312-917c50e4047b?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MXx8dG9ybmFkb3xlbnwwfHwwfHx8MA%3D%3D&auto=format&fit=crop&w=800&q=60' className="result-image" alt="image title"/>
            <div className="video-duration">
              <div className="tri-icon"></div>
              <span>1:22:02</span>
            </div>
          </Grid>
          <Grid col={true} className='result-meta-data'>
            <span className='published-date'>about 5 years ago</span>
            <div className='result-title'>
              <a href="" className='result-title-link'>
                <h2 className='result-title-label'>
                  Enhanced Fujita Scale for Tornadoes
                </h2>
              </a>
            </div>
            <div className='result-desc'>
              <p>Incredible For tornado safety tips and information, visit: weather.gov/tornado</p>
              <div className='result-url-text'>https://www.youtube.com/watch?v=Bl41fLm2KGs</div>
            </div>
          </Grid>
        </Grid>
        <Grid row className="row-mobile-divider"></Grid>
      </GridContainer>
      <GridContainer className='result-divider'>
        <Grid row gap="md">
        </Grid>
      </GridContainer>
    </div>
  );
};
