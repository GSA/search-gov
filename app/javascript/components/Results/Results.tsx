import React from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';
import { NoResults } from './NoResults/NoResults';
// import { HealthTopics } from './HealthTopics/HealthTopics';
// import { ImagesPage } from './ImagesPage/ImagesPage';
import { RssNews } from './RssNews/RssNews';
// import { Videos } from './Videos/Videos';
// import { FedRegister } from './FedRegister/FedRegister';
// import { Jobs } from './Jobs/Jobs';

import { truncateUrl } from '../../utils';

import './Results.css';

interface ResultsProps {
  query?: string
  results?: {
    title: string,
    url: string,
    description: string,
    updatedDate?: string,
    publishedDate?: string,
    thumbnailUrl?: string
  }[] | null;
  additionalResults?: {
    recommendedBy: string;
    textBestBets?: {
      title: string;
      url: string;
      description: string;
    }[];
    graphicsBestBet?: {
      title: string;
      titleUrl?: string;
      imageUrl?: string;
      imageAltText?: string;
      links?: {
        title: string;
        url: string;
      }[];
    };
    oldNews?: {
      title: string;
      link: string;
      description: string;
      publishedAt: string;
    }[];
    newNews?: {
      title: string;
      link: string;
      description: string;
      publishedAt: string;
    }[];
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
  locale: {
    t(key: string, values: Record<string, string>): string;
  };
}

export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical, locale }: ResultsProps) => {
  const URL_LENGTH = 80;
  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && (
          <BestBets
            {...additionalResults}
            parse={parse}
          />
        )}

        <div id="results" className="search-result-item-wrapper">
          {/* RSS - new news */}
          {
            (additionalResults && 
              additionalResults?.newNews && 
              additionalResults?.newNews?.length > 0) && 
              <RssNews 
                news={additionalResults.newNews} 
                recommendedBy={additionalResults.recommendedBy}
                parse={parse}
              />
          }

          {/* Jobs - To Do as part of backend integration */}
          {/* <Jobs /> */}
          
          {/* Health topics - To Do as part of backend integration */}
          {/* <HealthTopics /> */}

          {/* Image page Components - To do with its integration task */}
          {/* <ImagesPage /> */}

          {/* Video module/page - To do with its integration task */}
          {/* <Videos /> */}

          {/* Federal register - To do with its integration task */}
          {/* <FedRegister /> */}

          {/* Results */}
          {results && results.length > 0 ? 
            <> 
              {results.map((result, index) => {
                return (
                  <GridContainer key={index} className='result search-result-item'>
                    <Grid row gap="md">
                      {vertical === 'image' &&
                      <Grid mobileLg={{ col: 4 }} className='result-thumbnail'>
                        <img src={result.thumbnailUrl} className="result-image" alt={result.title}/>
                      </Grid>
                      }
                      <Grid col={true} className='result-meta-data'>
                        {result.publishedDate && (<span className='published-date'>{result.publishedDate}</span>)}
                        {result.updatedDate && (<span className='published-date'>{' '}&#40;Updated on {result.updatedDate}&#41;</span>)}
                        <div className='result-title'>
                          <a href={result.url} className='result-title-link'>
                            <h2 className='result-title-label'>
                              {parse(result.title)} 
                              {/* ToDo: This need to be dynamic */}
                              <span className='filetype-label'>PDF</span>
                            </h2>
                          </a>
                        </div>
                        <div className='result-desc'>
                          <p>{parse(result.description)}</p>
                          <div className='result-url-text'>{truncateUrl(result.url, URL_LENGTH)}</div>
                        </div>
                      </Grid>
                    </Grid>
                    <Grid row className="row-mobile-divider"></Grid>
                  </GridContainer>
                );
              })}
              <GridContainer className='result-divider'>
                <Grid row gap="md">
                </Grid>
              </GridContainer></> : (
              <NoResults errorMsg={locale.t('noResultsForAndTry', { query })} />
            )}

          {/* RSS - old news */}
          {
            (additionalResults && 
              additionalResults?.oldNews && 
              additionalResults?.oldNews?.length > 0) && 
              <RssNews 
                news={additionalResults.oldNews} 
                recommendedBy={additionalResults.recommendedBy}
                parse={parse}
              />
          }
        </div>
      </div>
      <Pagination 
        totalPages={totalPages}
        pathname={window.location.href}
        unboundedResults={unboundedResults}
      />
    </>
  );
};
