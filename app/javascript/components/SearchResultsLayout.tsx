import React, { useState, useEffect } from 'react';
import { Grid, GridContainer } from '@trussworks/react-uswds';
import { createGlobalStyle } from 'styled-components';
import { darken } from 'polished';
import { I18n } from 'i18n-js';

import './SearchResultsLayout.css';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';
import { LanguageContext } from '../contexts/LanguageContext';
import { StyleContext, styles } from '../contexts/StyleContext';
export interface NavigationLink {
  active: boolean; label: string; url: string, facet: string;
}

export interface PageData {
  affiliate: string;
  displayLogoOnly: boolean;
  title: string;
  logo: {
    url: string;
    text: string;
  };
  homepageUrl: string;
  showVoteOrgLink?: boolean;
}

export interface Language {
  code: string;
  rtl: boolean;
}

interface FacetsProps {
  aggregations?: AggregationData[];
}

interface AggregationItem {
  aggKey: string;
  docCount: number;
}

type AggregationData = {
  [key in string]: AggregationItem[];
};

export interface FontsAndColors {
  activeSearchTabNavigationColor: string;
  bannerBackgroundColor: string;
  bannerTextColor: string;
  bestBetBackgroundColor: string;
  buttonBackgroundColor: string;
  footerAndResultsFontFamily: string;
  footerBackgroundColor: string;
  footerLinksTextColor: string;
  headerBackgroundColor: string;
  headerLinksFontFamily: string;
  headerNavigationBackgroundColor: string;
  headerPrimaryLinkColor: string;
  headerSecondaryLinkColor: string;
  headerTextColor: string;
  healthBenefitsHeaderBackgroundColor: string;
  identifierBackgroundColor: string;
  identifierFontFamily: string;
  identifierHeadingColor: string;
  identifierLinkColor: string;
  pageBackgroundColor: string;
  primaryNavigationFontFamily: string;
  primaryNavigationFontWeight: string;
  resultDescriptionColor: string;
  resultTitleColor: string;
  resultTitleLinkVisitedColor: string;
  resultUrlColor: string;
  searchTabNavigationLinkColor: string;
  sectionTitleColor: string;
}

interface SearchResultsLayoutProps {
  page: PageData;
  resultsData?: {
    total?: number;
    totalPages: number;
    unboundedResults: boolean;
    results: {
      title: string;
      url: string;
      description: string;
      updatedDate?: string;
      publishedDate?: string;
      thumbnailUrl?: string;
      fileType?: string,
      youtube?: boolean;
      youtubePublishedAt?: string;
      youtubeThumbnailUrl?: string;
      youtubeDuration?: string;
      blendedModule?: string;
      tags?: string[]
    }[] | null;
    aggregations?: AggregationData[];
  } | null;
  additionalResults?: {
    recommendedBy: string;
    newNews?: {
      title: string,
      link: string,
      description: string,
      publishedAt: string
    }[];
    oldNews?: {
      title: string,
      link: string,
      description: string,
      publishedAt: string
    }[];
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
    youtubeNewsItems?: {
      link: string;
      title: string;
      description: string;
      publishedAt: string;
      youtubeThumbnailUrl: string;
      duration: string;
    }[];
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
    healthTopic?: {
      title: string;
      description: string;
      url: string;
      studiesAndTrials?: {
        title: string;
        url: string;
      }[];
      relatedTopics?: {
        title: string;
        url: string;
      }[];
    };
  } | null;
  vertical: string;
  params?: {
    query?: string;
  };
  translations: {
    en?: { noResultsForAndTry: string };
  };
  language?: Language;
  relatedSites?: {
    label: string;
    link: string;
  }[];
  alert?: {
    title: string;
    text: string;
  };
  spellingSuggestion?: {
    suggested: string;
    original: string;
    originalUrl: string;
    originalQuery: string;
    suggestedQuery: string;
    suggestedUrl: string;
  };
  sitelimit?: {
    sitelimit: string;
    url: string;
  };
  navigationLinks: NavigationLink[];
  extendedHeader: boolean;
  fontsAndColors: FontsAndColors;
  footerLinks?: {
    title: string;
    url: string;
  }[];
  primaryHeaderLinks?: {
    title: string;
    url: string;
  }[];
  secondaryHeaderLinks?: {
    title: string;
    url: string;
  }[];
  identifierContent?: {
    domainName: string | null;
    parentAgencyName: string | null;
    parentAgencyLink: string | null;
    logoUrl: string | null;
    logoAltText: string | null;
    lookingForGovernmentServices: boolean | null;
  };
  identifierLinks?:
    | {
        title: string;
        url: string;
      }[]
    | null;
  relatedSearches?: { label: string; link: string }[];
  newsLabel?: {
    newsAboutQuery: string;
    results:
      | {
          title: string;
          feedName: string;
          publishedAt: string;
        }[]
      | null;
  } | null;
  relatedSitesDropdownLabel?: string;
  agencyName?: string;
  jobsEnabled?: boolean;
  noResultsMessage?: {
    text?: string;
    urls?: {
      title: string;
      url: string;
    }[];
  };
  facetsEnabled: boolean
}

const GlobalStyle = createGlobalStyle<{ styles: { pageBackgroundColor: string; buttonBackgroundColor: string; facetsEnabled: boolean } }>`

  @media (min-width: 64em){
    .usa-header--extended .usa-navbar,
    .usa-header--extended .usa-nav__inner,
    .usa-banner__inner {
      max-width: ${(props) => props.styles.facetsEnabled === true ? '70rem': '64rem'};
    }
  }
  .serp-result-wrapper > .grid-container {
    max-width: ${(props) => props.styles.facetsEnabled === true ? '65rem': '54rem'}
  }

  .serp-result-wrapper {
    background-color: ${(props) => props.styles.pageBackgroundColor};
  }
  .usa-button {
    background-color: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }

  .usa-search .usa-button {
    background-color: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }

  @media (max-width: 768px){
    .serp-facets-container{
      display: ${(props) => props.styles.facetsEnabled === true ? 'none': 'block'};
    }
    .serp-main-container{
       width: ${(props) => props.styles.facetsEnabled === true ? '100%': '100%'};
    }
  }

  .facets-close-icon-wrapper{
    background-color: ${(props) => props.styles.buttonBackgroundColor};
  }
`;

const isBasicHeader = (extendedHeader: boolean): boolean => {
  return !extendedHeader;
};

const videosUrl = (links: NavigationLink[]) => links.find((link) => link.facet === 'YouTube')?.url ;

// eslint-disable-next-line complexity
const SearchResultsLayout = ({ page, resultsData, additionalResults, vertical, params = {}, translations, language = { code: 'en', rtl: false }, relatedSites = [], extendedHeader, footerLinks, primaryHeaderLinks, secondaryHeaderLinks, fontsAndColors, newsLabel, identifierContent, identifierLinks, navigationLinks, relatedSitesDropdownLabel = '', alert, spellingSuggestion, relatedSearches, sitelimit, noResultsMessage, jobsEnabled, agencyName, facetsEnabled }: SearchResultsLayoutProps) => {
  const [isMobileView, setMobileView] = useState(false);

  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = language.code;

  useEffect(() => {
    // checking/setting the mobile view for handling mobile facets UI
    if (window.innerWidth < 640) {
      setMobileView(true);
    }
  }, []);

  return (
    <LanguageContext.Provider value={i18n}>
      <StyleContext.Provider value={fontsAndColors ? fontsAndColors : styles}>
        <StyleContext.Consumer>
          {(value) => <GlobalStyle styles={{ ...value, facetsEnabled }} />}
        </StyleContext.Consumer>
        <Header
          page={page}
          isBasic={isBasicHeader(extendedHeader)}
          primaryHeaderLinks={primaryHeaderLinks}
          secondaryHeaderLinks={secondaryHeaderLinks}
        />

        <div className="usa-section serp-result-wrapper">
          <GridContainer>
            <Grid row>
              {facetsEnabled && resultsData && (
                <Grid tablet={{ col: 3 }} className="serp-facets-container">
                  {!isMobileView && resultsData.aggregations && (
                    <Facets aggregations={resultsData.aggregations} />
                  )}
                </Grid>
              )}
              <Grid
                tablet={{ col: facetsEnabled ? 9 : 12 }}
                className="serp-main-container"
              >
                <SearchBar
                  agregations={resultsData?.aggregations}
                  query={params.query}
                  relatedSites={relatedSites}
                  navigationLinks={navigationLinks}
                  relatedSitesDropdownLabel={relatedSitesDropdownLabel}
                  alert={alert}
                  facetsEnabled={facetsEnabled}
                  mobileView={isMobileView}
                />

                {/* This ternary is needed to handle the case when Bing pagination leads to a page with no results */}
                {resultsData ? (
                  <Results
                    page={page}
                    results={resultsData.results}
                    vertical={vertical}
                    totalPages={resultsData.totalPages}
                    total={resultsData.total}
                    query={params.query}
                    unboundedResults={resultsData.unboundedResults}
                    additionalResults={additionalResults}
                    newsAboutQuery={newsLabel?.newsAboutQuery}
                    spellingSuggestion={spellingSuggestion}
                    videosUrl={videosUrl(navigationLinks)}
                    relatedSearches={relatedSearches}
                    noResultsMessage={noResultsMessage}
                    sitelimit={sitelimit}
                    jobsEnabled={jobsEnabled}
                    agencyName={agencyName}
                    facetsEnabled={facetsEnabled}
                  />
                ) : params.query ? (
                  <Results
                    page={page}
                    vertical={vertical}
                    totalPages={null}
                    query={params.query}
                    unboundedResults={true}
                    noResultsMessage={noResultsMessage}
                  />
                ) : (
                  <></>
                )}
              </Grid>
            </Grid>
          </GridContainer>
        </div>

        <Footer footerLinks={footerLinks} />
        <Identifier
          identifierContent={identifierContent}
          identifierLinks={identifierLinks}
          showVoteOrgLink={page.showVoteOrgLink}
        />
      </StyleContext.Provider>
    </LanguageContext.Provider>
  );
};

export default SearchResultsLayout;
