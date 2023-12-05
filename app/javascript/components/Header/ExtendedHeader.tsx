import React from 'react';
import { Header as UswdsHeader, Logo, Title, NavMenuButton, ExtendedNav } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

import './ExtendedHeader.css';

export const ExtendedHeader = ({ page, toggleMobileNav, mobileNavOpen, fontsAndColors }: HeaderProps) => {
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
          {page.logo?.url && (
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
          )}
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
