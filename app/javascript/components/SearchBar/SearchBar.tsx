import React, { useState, useContext, useEffect } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { VerticalNav } from './../VerticalNav/VerticalNav';
import { Alert } from './../Alert/Alert';
import { getUriWithParam } from '../../utils';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';
import { checkSearchIconColorContrast } from '../../utils';

import './SearchBar.css';

const searchMagnifySvgIcon = () => {
  return (
    <svg role="img" xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24" className="usa-search__submit-icon">
      <title>Search</title>
      <path d="M0 0h24v24H0z" fill="none"/>
      <path className="search-icon-glass" fill="#FFFFFF" d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
    </svg>
  );
};

interface SearchBarProps {
  query?: string;
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
  relatedSitesDropdownLabel?: string;
  alert?: {
    title: string;
    text: string;
  }
}

export const SearchBar = ({ query = '', relatedSites = [], navigationLinks = [], relatedSitesDropdownLabel = '', alert }: SearchBarProps) => {
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

  useEffect(() => {
    checkSearchIconColorContrast('usa-button', 'search-icon-glass');
  }, []);

  return (
    <div id="serp-search-bar-wrapper">
      <GridContainer>
        {alert && <Alert title={alert.title} text={alert.text}/>}

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
                placeholder={i18n.t('searchLabel')}
                type="search" 
                name="searchQuery" 
                value={searchQuery} 
                onChange={handleSearchQueryChange}
                data-testid="search-field" 
              />
              <button className="usa-button" type="submit" data-testid="search-submit-btn">
                {searchMagnifySvgIcon()}
              </button>
            </form>
          </Grid>
        </Grid>
        
        <Grid row>
          <Grid tablet={{ col: true }}>
            <VerticalNav relatedSites={relatedSites} navigationLinks={navigationLinks} relatedSitesDropdownLabel={relatedSitesDropdownLabel} />
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
