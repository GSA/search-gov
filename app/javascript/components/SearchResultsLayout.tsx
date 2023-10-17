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
      commentsCloseOn: string;
      contributingAgencyNames: [string];
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
  navigationLinks?: { active: boolean; label: string; link: string; }[];
  extendedHeader: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
  relatedSearches?: { label: string; link: string; }[];
  newsLabel?: {
    newsAboutQuery: string;
    results: {
      title: string;
      feedName: string,
      publishedAt: string
    }[] | null;
  } | null;
}

// To be updated
const getAffiliateTitle = (): string => {
  return 'Search.gov';
};

const isBasicHeader = (extendedHeader: boolean): boolean => {
  return !extendedHeader;
};

const SearchResultsLayout = ({ resultsData, additionalResults, vertical, params = {}, translations, currentLocale = 'en', relatedSites = [], extendedHeader, fontsAndColors, newsLabel }: SearchResultsLayoutProps) => {
  const i18n = new I18n(translations);
  i18n.defaultLocale = 'en';
  i18n.enableFallback = true;
  i18n.locale = currentLocale;

  additionalResults.federalRegisterDocuments = [
    {
      title: "Expand the Definition of a Public Assistance Household",
      htmlUrl: "https://gsa.gov/",
      commentsCloseOn: "October 12, 2023",
      contributingAgencyNames: ["Social Security Administarion"],
      documentNumber: "2016-10932",
      documentType: "Proposed Rule",
      publicationDate: "January 02, 2020",
      startPage: 29212,
      endPage: 29215,
      pageLength: 4
    },
    {
      title: "Unsuccessful Work Attempts and Expedited Reinstatement Eligibility",
      htmlUrl: "https://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work-attempts-and-expedited-reinstatement-eligibility",
      commentsCloseOn: "April 05, 2022",
      contributingAgencyNames: ["Social Security Administarion"],
      documentNumber: "2013-18148",
      documentType: "Rule",
      publicationDate: "January 02, 2020",
      startPage: 29212,
      endPage: 29215,
      pageLength: 5
    },
    {
      title: "Unsuccessful Work Attempts and Expedited Reinstatement Eligibility",
      htmlUrl: "https://www.federalregister.gov/articles/2016/05/11/2016-10932/unsuccessful-work-attempts-and-expedited-reinstatement-eligibility",
      commentsCloseOn: "April 05, 2024",
      contributingAgencyNames: ["Social Security Administarion"],
      documentNumber: "2013-18148",
      documentType: "Rule",
      publicationDate: "January 02, 2020",
      startPage: 29212,
      endPage: 29215,
      pageLength: 5
    },
  ]

  console.log({additionalResults});

  return (
    <LanguageContext.Provider value={i18n}>
      <Header 
        title={getAffiliateTitle()}
        isBasic={isBasicHeader(extendedHeader)}
        fontsAndColors={fontsAndColors}
      />
     
      <div className="usa-section serp-result-wrapper">
        <Facets />
        <SearchBar query={params.query} relatedSites={relatedSites} />
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
          />) : params.query ? (
          <Results 
            vertical={vertical}
            totalPages={null}
            query={params.query}
            unboundedResults={true}
          />) : <></>}
      </div>

      <Footer />
      <Identifier />
    </LanguageContext.Provider>
  );
};

export default SearchResultsLayout;
