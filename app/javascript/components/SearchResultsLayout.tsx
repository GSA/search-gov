import React from 'react';

import { Header } from './Header';
import { Facets } from './Facets/Facets';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';
import { Footer } from './Footer/Footer';
import { Identifier } from './Identifier/Identifier';
interface SearchResultsLayoutProps {
  results: {}[];
  vertical: string;
  params?: string;
};

//To be updated
const getAffiliateTitle = (): string => {
  return "Search.gov";
}

//To be updated
const isBasicHeader = (): boolean => {
  return true;
}

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
}

export default SearchResultsLayout;
