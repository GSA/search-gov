import * as React from 'react';

import { Header } from './Header/Header';
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

const SearchResultsLayout = (props: SearchResultsLayoutProps) => {
  return (
    <React.Fragment>
      <Header 
        title="Search.gov" 
      />
      <Facets />
      <SearchBar 
        results={props.results} 
      />
      <Results 
        results={props.results} 
        vertical={props.vertical}
      />
      <Footer />
      <Identifier />
    </React.Fragment>
  );
}

export default SearchResultsLayout;
