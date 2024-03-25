import React, { useContext } from 'react';
import styled from 'styled-components';
import { GridContainer, Grid } from '@trussworks/react-uswds';
import parse from 'html-react-parser';

import { Pagination } from './../Pagination/Pagination';
import { BestBets } from './BestBets';
import { NoResults } from './NoResults/NoResults';
import { LanguageContext } from '../../contexts/LanguageContext';
import { StyleContext } from '../../contexts/StyleContext';

import { ResultGrid } from './ResultGrid/ResultGrid';
import { ResultsCount } from './ResultsCount/ResultsCount';
import { HealthTopics } from './HealthTopics/HealthTopics';
import { ImagesPage } from './ImagesPage/ImagesPage';
import { RssNews } from './RssNews/RssNews';
import { VideosModule } from './Videos/VideosModule';
import { Video } from './Videos/Video';
import { FedRegister } from './FedRegister/FedRegister';
import { Jobs } from './Jobs/Jobs';
import { SiteLimitAlert } from './SiteLimitAlert/SiteLimitAlert';
import { RelatedSearches } from './RelatedSearches/RelatedSearches';
import { SpellingSuggestion } from './SpellingSuggestion/SpellingSuggestion';
import { FontsAndColors, PageData } from '../SearchResultsLayout';

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
  fileType?: string,
  altText?: string,
  youtube?: boolean,
  youtubePublishedAt?: string,
  youtubeThumbnailUrl?: string,
  youtubeDuration?: string,
  blendedModule?: string
};
interface ResultsProps {
  page: PageData;
  query?: string;
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
      positionLocation: string;
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
  total?: number;
  vertical: string;
  newsAboutQuery?: string;
  spellingSuggestion?: {
    suggested: string;
    original: string;
    originalUrl: string;
    originalQuery: string;
    suggestedQuery: string;
    suggestedUrl: string;
  };
  videosUrl?: string;
  relatedSearches?: { label: string; link: string; }[];
  noResultsMessage?: {
    text?: string;
    urls?: {
      title: string;
      url: string;
    }[];
  };
  sitelimit?: {
    sitelimit: string;
    url: string;
  };
  jobsEnabled?: boolean
  agencyName?: string
}

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  font-family: ${(props) => props.styles.footerAndResultsFontFamily};
  .result-title-label > .result-title-link {
    color: ${(props) => props.styles.resultTitleColor};
  }
  .result-title-label > .result-title-link:visited {
    color: ${(props) => props.styles.resultTitleLinkVisitedColor};
  }
  .result-desc > p {
    color: ${(props) => props.styles.resultDescriptionColor};
  }
  .result-desc .result-url-text {
    color: ${(props) => props.styles.resultUrlColor};
  }
`;

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
export const Results = ({ page, query = '', results = null, additionalResults = null, unboundedResults, totalPages = null, newsAboutQuery = '', spellingSuggestion, videosUrl, relatedSearches, sitelimit, noResultsMessage, total, jobsEnabled, agencyName, vertical }: ResultsProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);
  const imagesResults = getImages(results);
  // Using unboundedResults as a shortcut to determining the search engine is possible since presently all successful
  // image searches are served by Searchgov. Depending on the outcome of SAT-1507, this may need to be updated to
  // account for Bing-delivered image search results where unboundedResults would be false.
  const isBing = unboundedResults === true;
  
  return (
    <>
      <div className='search-result-wrapper' id='main-content'>
        {sitelimit && (
          <SiteLimitAlert {...sitelimit} query={query} />
        )}

        {total && total > 0 ? <ResultsCount total={total}/>  : <></>}

        {spellingSuggestion && (
          <SpellingSuggestion 
            {...spellingSuggestion}
            affiliate={page?.affiliate ?? ''}
            vertical={vertical}
          />
        )}

        {additionalResults && (
          <BestBets
            {...additionalResults}
            affiliate={page?.affiliate ?? ''}
            query={query}
            vertical={vertical}
          />
        )}

        <div id="results" className="search-result-item-wrapper">
          <StyledWrapper styles={styles}>
            {additionalResults?.healthTopic && 
              <HealthTopics 
                {...additionalResults.healthTopic}
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
              />
            }

            {jobsEnabled &&
              <Jobs 
                jobs={additionalResults?.jobs}
                agencyName={agencyName}
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
              />
            }

            {/* Video module */}
            {additionalResults?.youtubeNewsItems &&
              <VideosModule
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
                videos={additionalResults.youtubeNewsItems}
                videosUrl={videosUrl} />
            }

            {/* RSS - new news */}
            {additionalResults?.newNews && 
              <RssNews 
                news={additionalResults.newNews} 
                newsLabel={newsAboutQuery}
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
              />
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
                        affiliate={page?.affiliate ?? ''}
                        description={result.description}
                        duration={result.youtubeDuration}
                        key={index}
                        link={result.url}
                        position={index+1}
                        publishedAt={result.youtubePublishedAt}
                        query={query}
                        title={result.title}
                        vertical={vertical}
                        youtubeThumbnailUrl={result.youtubeThumbnailUrl} 
                      />
                    );
                  }
                  return (
                    <ResultGrid key={index}
                      result={result}
                      affiliate={page?.affiliate ?? ''}
                      query={query}
                      vertical={vertical}
                      position={index+1} />
                  );
                })}
                <GridContainer className={`content-provider ${isBing ? 'bing' : ''}`}>
                  <span className='powered-by'>{parse(i18n.t('poweredBy'))} </span>
                  <span className='engine'>{isBing ? 'Bing' : 'Search.gov'}</span>
                </GridContainer>
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
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
              />
            }

            {/* RSS - old news */}
            {additionalResults?.oldNews && 
              <RssNews 
                news={additionalResults.oldNews} 
                newsLabel={newsAboutQuery}
                affiliate={page?.affiliate ?? ''}
                query={query}
                vertical={vertical}
              />
            }

            {relatedSearches && relatedSearches.length > 0 && 
              <RelatedSearches 
                affiliate={page?.affiliate ?? ''}
                query={query}
                relatedSearches={relatedSearches}
                vertical={vertical}/>
            }
          </StyledWrapper>
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
