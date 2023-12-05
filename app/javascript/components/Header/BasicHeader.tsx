import React from 'react';
import { Header as UswdsHeader, PrimaryNav, Logo, Title, NavMenuButton } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

import './BasicHeader.css';

export const BasicHeader = ({ page, toggleMobileNav, mobileNavOpen, fontsAndColors }: HeaderProps) => {
  const primaryNavItems = [
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>{'Primary link 1'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>{'Primary link 2'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>{'Primary link 3'}</span>
    </a>
  ];

  return (
    <>
      <UswdsHeader basic>
        <div className="usa-nav-container">
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
            <NavMenuButton
              label="Menu"
              onClick={toggleMobileNav}
              className="usa-menu-btn"
              data-testid="usa-menu-mob-btn"
            />
          </div>

          <PrimaryNav
            aria-label="Primary navigation"
            items={primaryNavItems}
            onToggleMobileNav={toggleMobileNav}
            mobileExpanded={mobileNavOpen}
          >
            <ul className="usa-nav__secondary-links" style={{ fontFamily: fontsAndColors?.headerLinksFontFamily }}>
              <li className="usa-nav__secondary-item">
                <a href="#linkOne">Secondary link 1</a>
              </li>
              <li className="usa-nav__secondary-item">
                <a href="#linkTwo">Secondary link 2</a>
              </li>
            </ul>
          </PrimaryNav>
        </div>
      </UswdsHeader>
    </>
  );
};
