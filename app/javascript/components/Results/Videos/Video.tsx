import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import Moment from 'react-moment';

interface VideoProps {
  link: string;
  title: string;
  description: string;
  publishedAt?: string;
  youtubeThumbnailUrl?: string;
  duration?: string;
}

export const Video = (video: VideoProps) => {
  return (
    <GridContainer className='result search-result-item search-result-video-item'>
      <Grid row gap="md">
        <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
          <img src={video.youtubeThumbnailUrl} className="result-image result-youtube-thumbnail" alt={video.title}/>
          <div className="video-duration">
            <div className="tri-icon"></div>
            <span>{video.duration}</span>
          </div>
        </Grid>
        <Grid col={true} className='result-meta-data'>
          <span className='published-date'> 
            <Moment fromNow>{video.publishedAt}</Moment> 
          </span>
          <div className='result-title'>
            <a href={video.link} className='result-title-link'>
              <h2 className='result-title-label'>
                {parse(video.title)}
              </h2>
            </a>
          </div>
          <div className='result-desc'>
            <p>{parse(video.description)}</p>
            <div className='result-url-text'>{video.link}</div>
          </div>
        </Grid>
      </Grid>
      <Grid row className="row-mobile-divider"></Grid>
    </GridContainer>
  );
};
