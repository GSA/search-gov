import React from 'react';

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
      title: string,
      url: string,
      thumbnail?: {
        url: string
      },
      description: string,
      updatedDate: string | null,
      publishedDate: string | null,
      thumbnailUrl: string | null
    }[] | null;
  } | null;
  additionalResults?: {
    recommendedBy: string;
    textBestBets: {
      title: string;
      url: string;
      description: string;
    }[];
  } | null;
  vertical: string;
  params?: {
    query?: string
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

const SearchResultsLayout = ({ resultsData, additionalResults, vertical, params = { query: '' } }: SearchResultsLayoutProps) => {
  return (
    <>
      <Header 
        title={getAffiliateTitle()}
        isBasic={isBasicHeader()} 
      />
     
      <div className="usa-section">
        <Facets />
        <SearchBar 
          query={params.query}
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
    </>
  );
};

export default SearchResultsLayout;
