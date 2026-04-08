import React, { useContext, useState, useEffect } from 'react';
import styled from 'styled-components';
import { GovBanner } from '@trussworks/react-uswds';
import { StyleContext } from '../../contexts/StyleContext';
import { LanguageContext } from '../../contexts/LanguageContext';
import { checkColorContrastAndUpdateStyle } from '../../utils';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';
import './index.css';

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
  .usa-banner__header, .usa-banner__button-text {
    background-color: ${(props) => props.styles.bannerBackgroundColor};
    color: ${(props) => props.styles.bannerTextColor};
  }
  .usa-banner__button::after, .usa-banner__button[aria-expanded=true]:hover::after {
    background-color: ${(props) => props.styles.bannerTextColor};
  }
`;

export const Header = ({ page, isBasic, primaryHeaderLinks, secondaryHeaderLinks }: HeaderProps) => {
  const styles = useContext(StyleContext);
  const i18n = useContext(LanguageContext);

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

  useEffect(() => {
    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.usa-menu-btn',
      foregroundItemClass: '.usa-menu-btn',
      isForegroundItemBtn: true
    });
  }, []);
 
  return (
    <>
      <a className="usa-skipnav" href="#main-content">
        {i18n.t('searches.skipToMainContent')}
      </a>
      <StyledGovBanner language={i18n.locale === 'es' ? 'spanish' : 'english'} styles={styles} />
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
