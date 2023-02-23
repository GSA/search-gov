import React from 'react';
import { Header as UswdsHeader, PrimaryNav, Logo, Title, NavMenuButton } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

import './BasicHeader.css';

const logoImg = "https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg";

export const BasicHeader = (props: HeaderProps) => {
  
  const primaryNavItems = [
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 1'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 2'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 3'}</span>
    </a>,
  ]

  return (
    <>
      <UswdsHeader basic>
        <div className="usa-nav-container">
          <div className="usa-navbar">
            <Logo
              className="width-full"
              size="slim"
              image={
                <img className="usa-identifier__logo" src={logoImg} alt="Site logo" />
              }
              heading={
                <Title>{props.title}</Title>
              }
            />
            <NavMenuButton
              label="Menu"
              onClick={props.toggleMobileNav}
              className="usa-menu-btn"
              data-testid="usa-menu-mob-btn"
            />
          </div>

          <PrimaryNav
            aria-label="Primary navigation"
            items={primaryNavItems}
            onToggleMobileNav={props.toggleMobileNav}
            mobileExpanded={props.mobileNavOpen}
            >
              <ul className="usa-nav__secondary-links">
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
}
