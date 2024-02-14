import React, { useContext } from 'react';
import styled from 'styled-components';
import { darken } from 'polished';
import { Header as UswdsHeader, PrimaryNav, NavMenuButton } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';
import { StyleContext } from '../../contexts/StyleContext';
import { Logo } from './Logo';
import { FontsAndColors } from '../SearchResultsLayout';

import './BasicHeader.css';

const StyledUswdsHeader = styled(UswdsHeader).attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  background-color: ${(props) => props.styles.headerBackgroundColor};
  .usa-nav__primary, .usa-nav__secondary-links {
    font-family: ${(props) => props.styles.headerLinksFontFamily};
  }
  a.usa-nav__link {
    color: ${(props) => props.styles.headerPrimaryLinkColor};
  }
  .usa-nav__secondary-item > a {
    color: ${(props) => props.styles.headerSecondaryLinkColor};
  }
  button.usa-menu-btn {
    background-color: ${(props) => props.styles.buttonBackgroundColor};
    &:hover {
      background-color: ${(props) => darken(0.10, props.styles.buttonBackgroundColor)};
    }
  }
`;

export const BasicHeader = ({ page, toggleMobileNav, mobileNavOpen, primaryHeaderLinks, secondaryHeaderLinks }: HeaderProps) => {
  const styles = useContext(StyleContext);

  const primaryNavItems =
    primaryHeaderLinks && primaryHeaderLinks.length > 0 ? (primaryHeaderLinks.map((link, index) => {
      return (
        <a className="usa-nav__link" href={link.url} key={index}>
          <span>{link.title}</span>
        </a>
      );
    })) : (
      [
        <></>
      ]
    );

  const showMobileMenu = (primaryHeaderLinks && primaryHeaderLinks.length > 0) || (secondaryHeaderLinks && secondaryHeaderLinks.length > 0);

  return (
    <>
      <StyledUswdsHeader basic styles={styles}>
        <div className="usa-nav-container">
          <div className="usa-navbar">
            <Logo page={page} />
            {showMobileMenu && <NavMenuButton
              label="Menu"
              onClick={toggleMobileNav}
              className="usa-menu-btn"
              data-testid="usa-menu-mob-btn"
            />}
          </div>

          <PrimaryNav
            aria-label="Primary navigation"
            items={primaryNavItems}
            onToggleMobileNav={toggleMobileNav}
            mobileExpanded={mobileNavOpen}
          >
            { secondaryHeaderLinks &&
              <ul  className="usa-nav__secondary-links">
                { secondaryHeaderLinks.map((link, index) => (
                    <li className="usa-nav__secondary-item" key={index}>
                      <a href={link.url} key={index}>
                        {link.title}
                      </a>
                    </li>
                  ))
                }
              </ul>
            }
          </PrimaryNav>
        </div>
      </StyledUswdsHeader>
    </>
  );
};
