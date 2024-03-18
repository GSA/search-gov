import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';
import Moment from 'react-moment';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultGridWrapper from '../ResultGrid/ResultGridWrapper';
import ResultTitle from '../ResultGrid/ResultTitle';

import './Video.css';

interface VideoProps {
  affiliate: string;
  description: string;
  duration?: string;
  link: string;
  position: number;
  publishedAt?: string;
  query: string;
  title: string;
  vertical: string;
  youtubeThumbnailUrl?: string;
}

export const Video = (video: VideoProps) => {
  const module = moduleCode.videos;

  return (
    <GridContainer className='result search-result-item search-result-video-item'>
      <ResultGridWrapper
        url={video.link}
        clickTracking={() => clickTracking(video.affiliate, module, video.query, video.position, video.link, video.vertical)}>
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
            <h2 className='result-title-label'>
              <ResultTitle 
                url={video.link}
                className='result-title-link'
                clickTracking={() => clickTracking(video.affiliate, module, video.query, video.position, video.link, video.vertical)}>
                {parse(video.title)}
              </ResultTitle>
            </h2>
          </div>
          <div className='result-desc'>
            {video.description && <p>{parse(video.description)}</p>}
            <div className='result-url-text'>{video.link}</div>
          </div>
        </Grid>
      </ResultGridWrapper>
      <Grid row className="row-mobile-divider"></Grid>
    </GridContainer>
  );
};
