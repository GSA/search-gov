import React from 'react';
import { I18n } from 'i18n-js';

import './SearchResultsLayout.css';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';

interface SearchResultsLayoutProps {
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
    }[];
    federalRegisterDocuments?: {
      title: string;
      documentType: string;
      documentNumber: number;
      publicationDate: string;
      commentsCloseOn: string;
      startPage: number;
      endPage: number;
      pageLength: number;
      contributingAgencyNames: string[];
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
  locale: {
    en?: { noResultsForAndTry: string }
  };
}

// To be updated
const getAffiliateTitle = (): string => {
  return 'Search.gov';
};

// To be updated
const isBasicHeader = (): boolean => {
  return true;
};

const SearchResultsLayout = ({ resultsData, additionalResults, vertical, params = {}, locale }: SearchResultsLayoutProps) => {
  const [language] = Object.keys(locale);
  const i18n = new I18n(locale);
  i18n.locale = language;

  return (
    <>
      <Header 
        title={getAffiliateTitle()}
        isBasic={isBasicHeader()} 
      />
     
      <div className="usa-section serp-result-wrapper">
        <Facets />
        <SearchBar 
          query={params.query}
          locale={i18n}
        />
        {/* This ternary is needed to handle the case when Bing pagination leads to a page with no results */}
        {resultsData ? (
          <Results 
            results={resultsData.results}
            vertical={vertical}
            totalPages={resultsData.totalPages}
            query={params.query}
            unboundedResults={resultsData.unboundedResults}
            additionalResults={additionalResults}
            locale={i18n}
          />) : params.query ? (
          <Results 
            vertical={vertical}
            totalPages={null}
            query={params.query}
            unboundedResults={true}
            locale={i18n}
          />) : <></>}
      </div>

      <Footer />
      <Identifier />
    </>
  );
};

export default SearchResultsLayout;
