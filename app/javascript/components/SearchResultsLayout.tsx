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
    bing: boolean;
    results: {
      title: string,
      url: string,
      thumbnail: {
        url: string
      },
      description: string,
      updatedDate: string,
      publishedDate: string,
      thumbnailUrl: string
    }[];
  }
  vertical: string;
  params: {
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

const SearchResultsLayout = (props: SearchResultsLayoutProps) => {
  return (
    <>
      <Header 
        title={getAffiliateTitle()}
        isBasic={isBasicHeader()} 
      />
     
      <div className="usa-section">
        <Facets />
        <SearchBar 
          query={props.params.query}
          results={props.resultsData === null ? null : props.resultsData.results} 
        />
        {props.resultsData && (<Results 
          results={props.resultsData.results} 
          vertical={props.vertical}
          totalPages={props.resultsData.totalPages}
        />)}
      </div>

      <Footer />
      <Identifier />
    </>
  );
};

export default SearchResultsLayout;
