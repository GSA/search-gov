import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';
import { NoResults } from './NoResults/NoResults';
import { LanguageContext } from '../../contexts/LanguageContext';

import { HealthTopics } from './HealthTopics/HealthTopics';
import { ImagesPage } from './ImagesPage/ImagesPage';
import { RssNews } from './RssNews/RssNews';
// import { Videos } from './Videos/Videos';
import { FedRegister } from './FedRegister/FedRegister';
import { Jobs } from './Jobs/Jobs';

import { truncateUrl } from '../../utils';

import './Results.css';

type Result = {
  title: string,
  url: string,
  description: string,
  updatedDate?: string,
  publishedAt?: string,
  publishedDate?: string,
  thumbnailUrl?: string,
  image?: boolean,
  altText?: string,
};
interface ResultsProps {
  query?: string
  results?: Result[] | null;
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
    jobs?: {
      positionTitle: string;
      positionUri: string;
      positionLocationDisplay: string;
      organizationName: string;
      minimumPay: number;
      maximumPay: number;
      rateIntervalCode: string;
      applicationCloseDate: string;
    }[];
    healthTopic?: {
      description: string;
      title: string;
      url: string;
      relatedTopics?: {
        title: string;
        url: string;
      }[];
      studiesAndTrials?: {
        title: string;
        url: string;
      }[];
    };
    federalRegisterDocuments?: {
      commentsCloseOn: string | null;
      contributingAgencyNames: string[];
      documentNumber: string;
      documentType: string;
      endPage: number;
      htmlUrl: string;
      pageLength: number;
      publicationDate: string;
      startPage: number;
      title: string;
    }[];
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
  newsAboutQuery?: string;
}

const getImages = (result: Result[] | null) => {
  const imageArr: { url: string, altText?: string, thumbnailUrl?: string }[] = [];
  if (result)
    result.forEach((res) => {
      if (res.image)
        imageArr.push({ url: res.url, altText: res.altText, thumbnailUrl: res.thumbnailUrl });
    });
  return imageArr;
};

// eslint-disable-next-line complexity
export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical, newsAboutQuery = '' }: ResultsProps) => {
  const i18n = useContext(LanguageContext);
  const URL_LENGTH = 80;
  const imagesResults = getImages(results);

  return (
    <>
      <div className='search-result-wrapper'>
        {additionalResults && (
          <BestBets
            {...additionalResults}
          />
        )}

        <div id="results" className="search-result-item-wrapper">
          {/* RSS - new news */}
          {additionalResults?.newNews && 
            <RssNews 
              news={additionalResults.newNews} 
              newsLabel={newsAboutQuery}
            />
          }

          {additionalResults?.jobs && 
            <Jobs 
              jobs={additionalResults.jobs}
            />
          }
          
          {additionalResults?.healthTopic && 
            <HealthTopics 
              {...additionalResults.healthTopic}
            />
          }

          {/* Video module/page - To do with its integration task */}
          {/* <Videos /> */}

          {/* Federal register - To do with its integration task */}
          {/* <FedRegister /> */}

          {/* Results: Images */}
          {imagesResults.length > 0 && <ImagesPage images={imagesResults}/>}
          
          {/* Results */}
          {results && results.length > 0 ? 
            <> 
              {results.map((result, index) => {
                if (result.image) {
                  return null;
                }
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
              <NoResults errorMsg={i18n.t('noResultsForAndTry', { query })} />
            )}

          {/* RSS - old news */}
          {additionalResults?.oldNews && 
            <RssNews 
              news={additionalResults.oldNews} 
              newsLabel={newsAboutQuery}
            />
          }

          {/* Federal register */}
          {additionalResults?.federalRegisterDocuments && 
            <FedRegister 
              fedRegisterDocs={additionalResults.federalRegisterDocuments}
              query={query}
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
