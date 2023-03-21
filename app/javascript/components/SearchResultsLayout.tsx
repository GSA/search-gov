import React from 'react';

import './SearchResultsLayout.css';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';
interface SearchResultsLayoutProps {
  results: {
    title: string,
    unescapedUrl: string,
    thumbnail: {
      url: string
    },
    content: string
  }[];
  vertical: string;
  params: {
    query: string
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
          results={props.results} 
        />
        <Results 
          results={props.results} 
          vertical={props.vertical}
        />
      </div>

      <Footer />
      <Identifier />
    </>
  );
};

export default SearchResultsLayout;
