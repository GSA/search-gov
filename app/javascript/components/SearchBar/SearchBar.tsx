import React, { useState, useContext } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { VerticalNav } from './../VerticalNav/VerticalNav';
// import { Alert } from './../Alert/Alert';
import { getUriWithParam } from '../../utils';
import { LanguageContext } from '../../contexts/LanguageContext';

import './SearchBar.css';

const logoImg = 'data:image/svg+xml;base64,PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIGhlaWdodD0iMjQiIHZpZXdCb3g9IjAgMCAyNCAyNCIgd2lkdGg9IjI0Ij48cGF0aCBkPSJNMCAwaDI0djI0SDB6IiBmaWxsPSJub25lIi8+PHBhdGggZmlsbD0iI2ZmZmZmZiIgZD0iTTE1LjUgMTRoLS43OWwtLjI4LS4yN0MxNS40MSAxMi41OSAxNiAxMS4xMSAxNiA5LjUgMTYgNS45MSAxMy4wOSAzIDkuNSAzUzMgNS45MSAzIDkuNSA1LjkxIDE2IDkuNSAxNmMxLjYxIDAgMy4wOS0uNTkgNC4yMy0xLjU3bC4yNy4yOHYuNzlsNSA0Ljk5TDIwLjQ5IDE5bC00Ljk5LTV6bS02IDBDNy4wMSAxNCA1IDExLjk5IDUgOS41UzcuMDEgNSA5LjUgNSAxNCA3LjAxIDE0IDkuNSAxMS45OSAxNCA5LjUgMTR6Ii8+PC9zdmc+';

interface SearchBarProps {
  query?: string;
  relatedSites?: {label: string, link: string}[];
}

export const SearchBar = ({ query = '', relatedSites = [] }: SearchBarProps) => {
  const [searchQuery, setSearchQuery] = useState(query);
  const searchUrlParam = 'query';

  const i18n = useContext(LanguageContext);

  const handleSearchQueryChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const element = event.target as HTMLInputElement;
    setSearchQuery(element.value);
  };

  const querySubmit = (event: React.FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    window.location.assign(getUriWithParam(window.location.href, searchUrlParam, searchQuery));
  };

  return (
    <div id="serp-search-bar-wrapper">
      <GridContainer>
        {/* Alert - To do with its integration task */}
        {/* <Alert /> */}

        <Grid row>
          <Grid tablet={{ col: true }}>
            <form 
              className="usa-search usa-search--small" 
              role="search" 
              onSubmit={querySubmit}>
              <label className="usa-sr-only" htmlFor="search-field">Search</label>
              <input 
                className="usa-input" 
                id="search-field" 
                placeholder={i18n.t('inputPlaceholder')}
                type="search" 
                name="searchQuery" 
                value={searchQuery} 
                onChange={handleSearchQueryChange}
                data-testid="search-field" 
              />
              <button className="usa-button" type="submit" data-testid="search-submit-btn">
                <img src={logoImg} className="usa-search__submit-icon" alt="Search"/>
              </button>
            </form>
          </Grid>
        </Grid>
        
        <Grid row>
          <Grid tablet={{ col: true }}>
            <VerticalNav relatedSites={relatedSites} />
          </Grid>
        </Grid>
        
        {!query &&
        <Grid row>
          <Grid tablet={{ col: true }}>
            <h4 className='no-result-error'>
              {i18n.t('emptyQuery')}
            </h4>
          </Grid>
        </Grid>}
      </GridContainer>
    </div>
  );
};
