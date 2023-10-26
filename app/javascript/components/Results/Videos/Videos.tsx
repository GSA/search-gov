import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import {Video} from './Video';

interface VideosProps {
  videos?: {
    link: string;
    title: string;
    description: string;
    publishedAt: string;
    youtubeThumbnailUrl: string;
    duration: string;
  }[];
}

export const Videos = ({videos=[]}: VideosProps) => {
  return (
    <>
      {videos?.length > 0 && (
        <div className='search-item-wrapper'>
          {videos?.map((video, index) => {
            return (<Video {...video} />);
          })}
          <GridContainer className='result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer>
        </div>
    )}
    </>
  );
};
