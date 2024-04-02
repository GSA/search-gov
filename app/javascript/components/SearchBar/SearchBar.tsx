import React, { useState, useContext, useEffect } from 'react';
import { GridContainer, Grid } from '@trussworks/react-uswds';

import { VerticalNav } from './../VerticalNav/VerticalNav';
import { Alert } from './../Alert/Alert';
import { getUriWithParam } from '../../utils';
import { LanguageContext } from '../../contexts/LanguageContext';
import { NavigationLink } from '../SearchResultsLayout';

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

const luminance = (red: number, green: number, blue: number) => {
  const rgb = [red, green, blue].map((index) => {
    const value = index / 255;
    return value <= 0.03928
      ? value / 12.92
      : Math.pow((value + 0.055) / 1.055, 2.4);
  });
  return rgb[0] * 0.2126 + rgb[1] * 0.7152 + rgb[2] * 0.0722;
};

const rgbToColorObject = (color: string) => {
  const rgbStrLen = 'rgb('.length;
  const colorArr = color.substring(rgbStrLen, color.lastIndexOf(')')).split(', ');
  return {
    red: parseInt(colorArr[0], 10),
    green: parseInt(colorArr[1], 10),
    blue: parseInt(colorArr[2], 10)
  };
};

const calculateRatio = (bgColor: string, fgColor: string) => {
  const color1rgb = rgbToColorObject(fgColor);
  const color2rgb = rgbToColorObject(bgColor);

  // calculate the relative luminance
  const color1luminance = luminance(color1rgb.red, color1rgb.green, color1rgb.blue);
  const color2luminance = luminance(color2rgb.red, color2rgb.green, color2rgb.blue);

  // calculate the color contrast ratio
  const ratio = color1luminance > color2luminance 
    ? ((color2luminance + 0.05) / (color1luminance + 0.05))
    : ((color1luminance + 0.05) / (color2luminance + 0.05));

  return ratio;
};

const checkSearchIconColorContrast = () => {
  const svgBtn = Array.from(document.getElementsByClassName('usa-button'))[0] as HTMLElement;
  const svgMagnifyIcon = Array.from(document.getElementsByClassName('search-icon-glass'))[0] as HTMLElement;

  const bgColor = window.getComputedStyle(svgBtn).getPropertyValue('background-color');
  const fgColor = window.getComputedStyle(svgMagnifyIcon).getPropertyValue('fill');

  const contrastRatio = calculateRatio(bgColor, fgColor);
  if (contrastRatio >= 1/4.5) {
    svgMagnifyIcon.style.filter = 'invert(1)';
  }
  
  /*
  AA-level small text: ${contrastRatio < 1/4.5 ? 'PASS' : 'FAIL' }
  AAA-level small text: ${contrastRatio < 1/7 ? 'PASS' : 'FAIL' }
  AAA-level large text: ${contrastRatio < 1/4.5 ? 'PASS' : 'FAIL' }
  AA-level large text: ${contrastRatio < 1/3 ? 'PASS' : 'FAIL' }
  */
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
    checkSearchIconColorContrast();
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
