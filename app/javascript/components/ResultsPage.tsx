import * as React from 'react';

import { Header } from './Header/Header';
import { SearchBar } from './SearchBar/SearchBar';
import { Results } from './Results/Results';

interface ResultsPageProps {
  results: any;
  params: any;
  vertical: any;
};

interface Nothing {};

class ResultsPage extends React.Component<ResultsPageProps, Nothing> {
  render () {
    return (
      <React.Fragment>
        <Header 
          title="Search.gov" 
        />
        <SearchBar 
          results={this.props.results} 
        />
        <Results 
          results={this.props.results} 
          vertical={this.props.vertical}
        />
      </React.Fragment>
    );
  }
}

export default ResultsPage;
