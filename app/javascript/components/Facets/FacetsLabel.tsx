import React, { useContext } from 'react';
import styled from 'styled-components';
import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors  } from '../SearchResultsLayout';

import './FacetsLabel.css';

const StyledWrapper = styled.div.attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  path.search-filer-icon {
    fill: ${(props) => props.styles.buttonBackgroundColor};
  }
`;

const searchFilterSvgIcon = () => {
  return (
    <svg role="img" xmlns="http://www.w3.org/2000/svg" height="24" viewBox="0 0 24 24" width="24" data-testid="filter-search-btn">
      <title>Filter</title>
      <path className="search-filer-icon" fill="#005EA2" d="M4.25 5.61C6.27 8.2 10 13 10 13v6c0 .55.45 1 1 1h2c.55 0 1-.45 1-1v-6s3.72-4.8 5.74-7.39A.998.998 0 0 0 18.95 4H5.04c-.83 0-1.3.95-.79 1.61z"/>
    </svg>
  );
};

export const FacetsLabel = () => {
  const styles = useContext(StyleContext);
  return (
    <StyledWrapper styles={styles}>
      <h3 className="filter-heading">
        {searchFilterSvgIcon()} 
        <span className="filter-heading-label">Filter search</span>
      </h3>
    </StyledWrapper>
  );
};
