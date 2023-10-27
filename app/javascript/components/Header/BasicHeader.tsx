import React, { useContext } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Header as UswdsHeader, PrimaryNav, Logo, Title, NavMenuButton } from '@trussworks/react-uswds';
import { StyleContext } from '../../contexts/StyleContext';

import { HeaderProps } from './../props';

import './BasicHeader.css';

const StyledUswdsHeader = styled(UswdsHeader).attrs<{ styles: { buttonBackgroundColor: string; headerLinksFontFamily: string, headerBackgroundColor: string, headerPrimaryLinkColor: string, headerSecondaryLinkColor: string; }; }>(props => ({
  styles: props.styles,
}))`
  background-color: ${props => props.styles.headerBackgroundColor};
  .usa-nav__primary, .usa-nav__secondary-links {
    font-family: ${props => props.styles.headerLinksFontFamily};
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

export const BasicHeader = ({ page, toggleMobileNav, mobileNavOpen }: HeaderProps) => {
  const styles = useContext(StyleContext);

  const primaryNavItems = [
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 1'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 2'}</span>
    </a>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'Primary link 3'}</span>
    </a>
  ];

  return (
    <>
      <StyledUswdsHeader basic styles={styles}>
        <div className="usa-nav-container">
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
      </StyledUswdsHeader>
    </>
  );
};
