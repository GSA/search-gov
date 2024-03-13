/* eslint-disable camelcase */

import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import { LanguageContext } from '../../../contexts/LanguageContext';
import { Video } from './Video';
import { clickTracking } from '../../../utils';
import { moduleCode } from '../../../utils/constants';
import ResultTitle from '../ResultGrid/ResultTitle';

interface VideosModuleProps {
  affiliate: string;
  query: string;
  vertical: string;
  videos?: {
    link: string;
    title: string;
    description: string;
    publishedAt: string;
    youtubeThumbnailUrl: string;
    duration: string;
  }[];
  videosUrl?: string;
}

export const VideosModule = ({ affiliate, query, vertical, videos=[], videosUrl }: VideosModuleProps) => {
  const i18n = useContext(LanguageContext);
  const module = (() => {
    return moduleCode.videos;
  })();

  return (
    <>
      {videos?.length > 0 && (
        <div className='search-item-wrapper'>
          {videos?.map((video, index) => {
            return (<Video
              {...video}
              affiliate={affiliate}
              key={index}
              position={index+1}
              query={query}
              vertical={vertical}
            />);
          })}
          {videosUrl && (
            <GridContainer className='result search-result-item margin-top-neg-2'>
              <Grid row gap="md">
                <Grid col={true} className='result-meta-data'>
                  <div className='result-title'>
                    <h2 className='result-title-label'>
                      <ResultTitle
                        url={videosUrl}
                        className='result-title-link more-title-link'
                        clickTracking={() => clickTracking(affiliate, module, query, videos.length+1, `${window.location.origin}${videosUrl}`, vertical)}>
                        {i18n.t('searches.moreNewsAboutQuery', { news_label: 'videos', query })}
                      </ResultTitle>
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
