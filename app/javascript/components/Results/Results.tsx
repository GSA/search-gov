import React, { useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';
import { NoResults } from './NoResults/NoResults';
import { LanguageContext } from '../../contexts/LanguageContext';

import { ResultGrid } from './ResultGrid/ResultGrid';
import { HealthTopics } from './HealthTopics/HealthTopics';
import { ImagesPage } from './ImagesPage/ImagesPage';
import { RssNews } from './RssNews/RssNews';
import { VideosModule } from './Videos/VideosModule';
import { Video } from './Videos/Video';
import { FedRegister } from './FedRegister/FedRegister';
import { Jobs } from './Jobs/Jobs';
import { RelatedSearches } from './RelatedSearches/RelatedSearches';
import { SpellingSuggestion } from './SpellingSuggestion/SpellingSuggestion';

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
  youtube?: boolean,
  youtubePublishedAt?: string,
  youtubeThumbnailUrl?: string,
  youtubeDuration?: string
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
    youtubeNewsItems?: {
      link: string;
      title: string;
      description: string;
      publishedAt: string;
      youtubeThumbnailUrl: string;
      duration: string;
    }[];
  } | null;
  unboundedResults: boolean;
  totalPages: number | null;
  vertical: string;
  newsAboutQuery?: string;
  spellingSuggestion?: {
    suggested: string;
    original: string;
  };
  videosUrl?: string;
  relatedSearches?: { label: string; link: string; }[]
  noResultsMessage?: {
    text?: string;
    urls?: {
      title: string;
      url: string;
    }[]
  };
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
export const Results = ({ query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, vertical, newsAboutQuery = '', spellingSuggestion, videosUrl, relatedSearches, noResultsMessage }: ResultsProps) => {
  const i18n = useContext(LanguageContext);
  const imagesResults = getImages(results);
  
  return (
    <>
      <div className='search-result-wrapper'>
        {spellingSuggestion && (
          <SpellingSuggestion {...spellingSuggestion}/>
        )}

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

          {/* Video module */}
          {additionalResults?.youtubeNewsItems && 
            <VideosModule videos={additionalResults.youtubeNewsItems} query={query} videosUrl={videosUrl} />
          }

          {/* Results: Images */}
          {imagesResults.length > 0 && <ImagesPage images={imagesResults}/>}
          
          {/* Results */}
          {results && results.length > 0 ? 
            <> 
              {results.map((result, index) => {
                if (result.image) {
                  return null;
                }
                if (result?.youtube) {
                  return (
                    <Video 
                      key={index}
                      link={result.url}
                      title={result.title}
                      description={result.description}
                      publishedAt={result.youtubePublishedAt}
                      youtubeThumbnailUrl={result.youtubeThumbnailUrl} 
                      duration={result.youtubeDuration}
                    />
                  );
                }
                return (
                  <ResultGrid key={index} vertical={vertical} result={result} />
                );
              })}
              <GridContainer className='result-divider'>
                <Grid row gap="md">
                </Grid>
              </GridContainer></> : (
              <NoResults 
                errorMsg={i18n.t('noResultsForAndTry', { query })}
                noResultsMessage={noResultsMessage}
              />
            )}

          {/* Federal register */}
          {additionalResults?.federalRegisterDocuments && 
            <FedRegister 
              fedRegisterDocs={additionalResults.federalRegisterDocuments}
              query={query}
            />
          }

          {/* RSS - old news */}
          {additionalResults?.oldNews && 
            <RssNews 
              news={additionalResults.oldNews} 
              newsLabel={newsAboutQuery}
            />
          }

          {relatedSearches && relatedSearches.length > 0 && 
            <RelatedSearches relatedSearches={relatedSearches}/>
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
