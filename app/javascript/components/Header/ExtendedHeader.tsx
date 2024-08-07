import React, { useContext, useEffect } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Header as UswdsHeader, NavMenuButton, ExtendedNav } from '@trussworks/react-uswds';

import { FontsAndColors } from '../SearchResultsLayout';
import { HeaderProps } from './../props';
import { Logo } from './Logo';
import { StyleContext } from '../../contexts/StyleContext';
import { LanguageContext } from '../../contexts/LanguageContext';
import { checkColorContrastAndUpdateStyle } from '../../utils';

import './ExtendedHeader.css';

const StyledUswdsHeader = styled(UswdsHeader).attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  background-color: ${(props) => props.styles.headerBackgroundColor};

  .usa-nav__primary a {
    font-family: ${(props) => props.styles.primaryNavigationFontFamily} !important;
    font-weight: ${(props) => props.styles.primaryNavigationFontWeight} !important;
  }

  .usa-nav__secondary {
    font-family: ${(props) => props.styles.headerLinksFontFamily};
  }

  .usa-nav {
    background-color: ${(props) => props.styles.headerNavigationBackgroundColor};
  }

  a.usa-nav__link {
    color: ${(props) => props.styles.headerPrimaryLinkColor} !important;
  }

  a.usa-nav__link:hover::after {
    background-color: ${(props) => props.styles.headerPrimaryLinkColor} !important;
  }

  .usa-nav__secondary-item > a {
    color: ${(props) => props.styles.headerSecondaryLinkColor};
  }

  @media (max-width: 63.99em){
    .usa-nav__secondary-item > a {
      color: ${(props) => props.styles.headerPrimaryLinkColor};
    }
  }

  button.usa-menu-btn {
    background-color: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }
`;

export const buildLink = (links: { title: string; url: string; }[], className?: string) => links.map((link, index) => (
  <a href={link.url} key={index} className={className} >
    <span>{link.title}</span>
  </a>
));

export const ExtendedHeader = ({ page, toggleMobileNav, mobileNavOpen, primaryHeaderLinks, secondaryHeaderLinks }: HeaderProps) => {
  const styles = useContext(StyleContext);
  const i18n = useContext(LanguageContext);

  const secondaryLinkItems = secondaryHeaderLinks ? buildLink(secondaryHeaderLinks) : [];
  const primaryLinkItems = primaryHeaderLinks ? buildLink(primaryHeaderLinks, 'usa-nav__link') : [];
  
  const showMobileMenu = (primaryHeaderLinks && primaryHeaderLinks.length > 0) || (secondaryHeaderLinks && secondaryHeaderLinks.length > 0);

  useEffect(() => {
    checkColorContrastAndUpdateStyle({
      backgroundItemClass: '.usa-header--extended .usa-nav',
      foregroundItemClass: '.usa-header--extended .usa-nav .usa-icon--size-3'
    });
  }, []);

  return (
    <StyledUswdsHeader extended={true} styles={styles}>
      <div className="usa-navbar">
        <Logo page={page} />
        {showMobileMenu && <NavMenuButton onClick={toggleMobileNav} label={i18n.t('searches.menu')} />}
      </div>
      <ExtendedNav
        aria-label={i18n.t('ariaLabelHeader')}
        primaryItems={primaryLinkItems}
        secondaryItems={secondaryLinkItems}
        mobileExpanded={mobileNavOpen}
        onToggleMobileNav={toggleMobileNav}
      />
    </StyledUswdsHeader>
  );
};
