/* eslint-disable camelcase */

import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { Video } from './Video';

interface VideosModuleProps {
  query: string,
  videos?: {
    link: string;
    title: string;
    description: string;
    publishedAt: string;
    youtubeThumbnailUrl: string;
    duration: string;
  }[],
  videosUrl?: string;
}

export const VideosModule = ({ query, videos=[], videosUrl }: VideosModuleProps) => {
  const i18n = useContext(LanguageContext);

  return (
    <>
      {videos?.length > 0 && (
        <div className='search-item-wrapper'>
          {videos?.map((video, index) => {
            return (<Video key={index} {...video} />);
          })}
          {videosUrl && (
            <GridContainer className='result search-result-item margin-top-neg-2'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <div className='result-title'>
                    <h2 className='result-title-label'>
                      <a href={videosUrl} className='result-title-link more-title-link'>{i18n.t('searches.moreNewsAboutQuery', { news_label: 'videos', query })}</a>
                    </h2>
                  </div>
                </Grid>
              </Grid>
            </GridContainer>
          )}
          <GridContainer className='result-divider result-divider'>
            <Grid row gap="md">
            </Grid>
          </GridContainer>
        </div>
      )}
    </>
  );
};
