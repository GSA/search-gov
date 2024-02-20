import React, { useContext, useState } from 'react';
import styled from 'styled-components';
import { GovBanner } from '@trussworks/react-uswds';
import { StyleContext } from '../../contexts/StyleContext';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

import { BasicHeader } from './BasicHeader';
import { ExtendedHeader } from './ExtendedHeader';
import { PageData } from '../SearchResultsLayout';

interface HeaderProps {
  page: PageData;
  isBasic: boolean;
  primaryHeaderLinks?: {
    title: string,
    url: string
  }[];
  secondaryHeaderLinks?: {
    title: string,
    url: string
  }[];
}

const StyledGovBanner = styled(GovBanner).attrs<{ styles: { bannerBackgroundColor: string; bannerTextColor: string; }; }>((props) => ({
  styles: props.styles
}))`
  .usa-banner__header {
    background-color: ${(props) => props.styles.bannerBackgroundColor};
    color: ${(props) => props.styles.bannerTextColor};
  }
`;

export const Header = ({ page, isBasic, primaryHeaderLinks, secondaryHeaderLinks }: HeaderProps) => {
  const styles = useContext(StyleContext);

  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const toggleMobileNav = (): void => {
    setMobileNavOpen((prevOpen) => !prevOpen);
  };

  const headerProps = {
    page,
    toggleMobileNav,
    mobileNavOpen,
    primaryHeaderLinks,
    secondaryHeaderLinks
  };
 
  return (
    <>
      <a className="usa-skipnav" href="#main-content">
        Skip to main content
      </a>
      <StyledGovBanner styles={styles} />
      <div className={`usa-overlay ${mobileNavOpen ? 'is-visible' : ''}`}></div>

      {isBasic ? 
        <BasicHeader
          {...headerProps}
        />:
        <ExtendedHeader 
          {...headerProps}
        />
      }
    </>
  );
};
