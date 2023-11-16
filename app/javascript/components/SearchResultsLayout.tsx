import React from 'react';
import { I18n } from 'i18n-js';

import './SearchResultsLayout.css';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';
import { LanguageContext } from '../contexts/LanguageContext';

export interface NavigationLink {
  active: boolean; label: string; url: string, facet: string;
}

export interface PageData {
  title: string;
  logo: {
    url: string;
    text: string;
  }
}

interface SearchResultsLayoutProps {
  page: PageData;
  resultsData?: {
    totalPages: number;
    unboundedResults: boolean;
    results: {
      title: string;
      url: string;
      description: string;
      updatedDate?: string;
      publishedDate?: string;
      thumbnailUrl?: string;
      youtube?: boolean;
      youtubePublishedAt?: string;
      youtubeThumbnailUrl?: string;
      youtubeDuration?: string;
    }[] | null;
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
      positionLocationDisplay: string;
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
    query?: string
  };
  translations: {
    en?: { noResultsForAndTry: string }
  };
  currentLocale?: string;
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
  };
  navigationLinks: NavigationLink[];
  extendedHeader: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
  footerLinks?: {
    title: string,
    url: string
  }[];
  identifierContent?: {
    domainName: string | null;
    parentAgencyName: string | null;
    parentAgencyLink: string | null;
  };
  identifierLinks?: {
    title: string,
    url: string
  }[] | null;
  relatedSearches?: { label: string; link: string; }[];
  newsLabel?: {
    newsAboutQuery: string;
    results: {
      title: string;
      feedName: string,
      publishedAt: string
    }[] | null;
  } | null;
  relatedSitesDropdownLabel?: string;
}

const isBasicHeader = (extendedHeader: boolean): boolean => {
  return !extendedHeader;
};

const videosUrl = (links: NavigationLink[]) => links.find((link) => link.facet === 'YouTube')?.url ;

const SearchResultsLayout = ({ page, resultsData, additionalResults, vertical, params = {}, translations, currentLocale = 'en', relatedSites = [], extendedHeader, footerLinks, fontsAndColors, newsLabel, identifierContent, identifierLinks, navigationLinks, relatedSitesDropdownLabel = '', alert, spellingSuggestion }: SearchResultsLayoutProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = currentLocale;

  return (
    <LanguageContext.Provider value={i18n}>
      <Header 
        page={page}
        isBasic={isBasicHeader(extendedHeader)}
        fontsAndColors={fontsAndColors}
      />
      {/* Below to be deleted once the backend task - SRCH-4576 and SRCH-4630 are done */}
      {/* <Header 
        title="Search.gov"
        logoUrl="https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg"
        isBasic={isBasicHeader(extendedHeader)}
        fontsAndColors={fontsAndColors}
      /> */}
     
      <div className="usa-section serp-result-wrapper">
        <Facets />

        <SearchBar query={params.query} relatedSites={relatedSites} navigationLinks={navigationLinks} relatedSitesDropdownLabel={relatedSitesDropdownLabel} alert={alert}/>

        {/* This ternary is needed to handle the case when Bing pagination leads to a page with no results */}
        {resultsData ? (
          <Results 
            results={resultsData.results}
            vertical={vertical}
            totalPages={resultsData.totalPages}
            query={params.query}
            unboundedResults={resultsData.unboundedResults}
            additionalResults={additionalResults}
            newsAboutQuery={newsLabel?.newsAboutQuery}
            spellingSuggestion={spellingSuggestion}
            videosUrl= {videosUrl(navigationLinks)}
          />) : params.query ? (
          <Results 
            vertical={vertical}
            totalPages={null}
            query={params.query}
            unboundedResults={true}
          />) : <></>}
      </div>

      <Footer 
        footerLinks={footerLinks}
      />
      <Identifier
        identifierContent={identifierContent}
        identifierLinks={identifierLinks}
      />
    </LanguageContext.Provider>
  );
};

export default SearchResultsLayout;
