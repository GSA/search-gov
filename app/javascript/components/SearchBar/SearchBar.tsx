import React, { useState, useContext, useEffect } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { VerticalNav } from './../VerticalNav/VerticalNav';
import { Alert } from './../Alert/Alert';
import { getUriWithParam, checkColorContrastAndUpdateStyle } from '../../utils';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';

import SlidingPane from 'react-sliding-pane';
import { FacetsLabel } from '../Facets/FacetsLabel';
import { Facets, AggregationData } from '../../components/Facets/Facets';
import 'react-sliding-pane/dist/react-sliding-pane.css';

import './SearchBar.css';

const searchMagnifySvgIcon = () => {
  const i18n = useContext(LanguageContext);

  return (
    <svg role="img" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" className="usa-search__submit-icon">
      <title>{i18n.t('search')}</title>
      <path d="M0 0h24v24H0z" fill="none"/>
      <path className="search-icon-glass" fill="#FFFFFF" d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"/>
    </svg>
  );
};

const facetsCloseSvgIcon = () => {
  return (
    <svg role="img" xmlns="http://www.w3.org/2000/svg" width="1em" height="1em" viewBox="0 0 24 24" focusable="false" className="facets-close-icon-svg">
      <title>Close Filter Panel</title>
      <path className="facets-close-icon" fill="#FFFFFF" d="M19 6.41 17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"></path>
    </svg>
  );
};

interface SearchBarProps {
  agregations?: AggregationData[];
  query?: string;
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
  relatedSitesDropdownLabel?: string;
  alert?: {
    title: string;
    text: string;
  }
  facetsEnabled?: boolean
  mobileView?: boolean
}

export const SearchBar = ({ query = '', relatedSites = [], navigationLinks = [], relatedSitesDropdownLabel = '', alert, facetsEnabled, mobileView, agregations }: SearchBarProps) => {
  const [isPaneOpen, setIsPaneOpen] = useState(false);
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
    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.usa-search .usa-button',
      foregroundItemClass: '.usa-search .usa-button .search-icon-glass'
    });

    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.facets-close-icon-wrapper',
      foregroundItemClass: '.facets-close-icon'
    });

    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.serp-facets-wrapper .see-results-button',
      foregroundItemClass: '.serp-facets-wrapper .see-results-button',
      isForegroundItemBtn: true
    });
  }, []);

  return (
    <div id="serp-search-bar-wrapper" className={facetsEnabled ? 'search-bar-mobile-facets-wrapper' : ''}>
      <GridContainer>
        {alert && <Alert title={alert.title} text={alert.text}/>}

        <Grid row>
          <Grid tablet={{ col: true }} className="search-bar-wrapper">
            <form
              className="usa-search usa-search--small"
              role="search"
              onSubmit={querySubmit}>
              <label className="usa-sr-only" htmlFor="search-field">{i18n.t('search')}</label>
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

          {facetsEnabled &&
            <div onClick={() => setIsPaneOpen(true)} className="mobile-facets-wrapper">
              <FacetsLabel />
            </div>
          }

          <SlidingPane
            className="facets-mobile-panel"
            title={<div className="facets-mobile-panel-label">Filter Search </div>}
            closeIcon={<div className="facets-panel-close-icon-wrapper" data-testid="filter-panel-close-btn"><div className="facets-panel-close-icon-label">Close</div><div className="facets-close-icon-wrapper">{facetsCloseSvgIcon()}</div></div>}
            overlayClassName="facets-mobile-panel-overlay"
            isOpen={isPaneOpen}
            onRequestClose={() => {
              setIsPaneOpen(false);
            }}
            width={mobileView ? '80' : '50'}
          >
            {agregations && <Facets aggregations={agregations} />}
          </SlidingPane>
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
