import React, { useContext } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Header as UswdsHeader, Logo, Title, NavMenuButton, ExtendedNav } from '@trussworks/react-uswds';
import { StyleContext } from '../../contexts/StyleContext';

import { HeaderProps } from './../props';

import './ExtendedHeader.css';

const StyledUswdsHeader = styled(UswdsHeader).attrs<{ styles: { buttonBackgroundColor: string; headerLinksFontFamily: string, headerBackgroundColor: string, headerPrimaryLinkColor: string, headerSecondaryLinkColor: string; secondaryHeaderBackgroundColor: string; }; }>(props => ({
  styles: props.styles,
}))`
  background-color: ${props => props.styles.headerBackgroundColor};
  .usa-nav__primary, .usa-nav__secondary {
    font-family: ${props => props.styles.headerLinksFontFamily};
  }
  .usa-nav {
    background-color: ${props => props.styles.secondaryHeaderBackgroundColor};
  }
  a.usa-nav__link {
    color: ${props => props.styles.headerPrimaryLinkColor};
  }
  .usa-nav__secondary-item > a {
    color: ${props => props.styles.headerSecondaryLinkColor};
  }
  button.usa-menu-btn {
    background-color: ${props => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${props => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }
`;

export const ExtendedHeader = ({ page, toggleMobileNav, mobileNavOpen }: HeaderProps) => {
  const styles = useContext(StyleContext);

  const secondaryLinkItems = [
    <a href="#linkOne" key="one">
      <span>Secondary link 1</span>
    </a>,
    <a href="#linkTwo" key="two">
      <span>Secondary link 2</span>
    </a>
  ];

  const primaryLinkItems = [
    <a href="#one" key="one" className="usa-nav__link">
      <span>Primary link 1</span>
    </a>,
    <a href="#two" key="two" className="usa-nav__link">
      <span>Primary link 2</span>
    </a>,
    <a href="#three" key="three" className="usa-nav__link">
      <span>Primary link 3</span>
    </a>
  ];
  
  return (
    <>
      <StyledUswdsHeader extended={true} styles={styles}>
        <div className="usa-navbar">
          <Logo
            className="width-full"
            size="slim"
            image={
              <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title} />
            }
            heading={
              <Title>{page.title}</Title>
            }
          />
          <NavMenuButton onClick={toggleMobileNav} label="Menu" />
        </div>
        <ExtendedNav
          primaryItems={primaryLinkItems}
          secondaryItems={secondaryLinkItems}
          mobileExpanded={mobileNavOpen}
          onToggleMobileNav={toggleMobileNav}
        />
      </StyledUswdsHeader>
    </>
  );
};
