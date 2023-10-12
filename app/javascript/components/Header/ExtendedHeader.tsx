import React from 'react';
import { Header as UswdsHeader, Logo, Title, NavMenuButton, ExtendedNav } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

import './ExtendedHeader.css';

const logoImg = 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg';

export const ExtendedHeader = ({ title, toggleMobileNav, mobileNavOpen, fontsAndColors }: HeaderProps) => {
  const secondaryLinkItems = [
    <a href="#linkOne" key="one">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>Secondary link 1</span>
    </a>,
    <a href="#linkTwo" key="two">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>Secondary link 2</span>
    </a>
  ];

  const primaryLinkItems = [
    <a href="#one" key="one" className="usa-nav__link">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>Primary link 1</span>
    </a>,
    <a href="#two" key="two" className="usa-nav__link">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>Primary link 2</span>
    </a>,
    <a href="#three" key="three" className="usa-nav__link">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>Primary link 3</span>
    </a>
  ];
  
  return (
    <>
      <UswdsHeader extended={true}>
        <div className="usa-navbar">
          <Logo
            className="width-full"
            size="slim"
            image={
              <img className="usa-identifier__logo" src={logoImg} alt="Site logo" />
            }
            heading={
              <Title>{title}</Title>
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
      </UswdsHeader>
    </>
  );
};
