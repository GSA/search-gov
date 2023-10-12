import React, { useState } from 'react';
import { GridContainer, Header, NavDropDownButton, Menu, PrimaryNav } from '@trussworks/react-uswds';
import { NavigationLink } from '../SearchResultsLayout';

import './VerticalNav.css';

interface VerticalNavProps {
  relatedSites?: {label: string, link: string}[];
  navigationLinks: NavigationLink[];
}

export const VerticalNav = ({ relatedSites = [], navigationLinks = [] }: VerticalNavProps) => {
  const [isOpen, setIsOpen] = useState([false, false]);
  const onToggle = (
    index: number,
    setIsOpen: React.Dispatch<React.SetStateAction<boolean[]>>
  ): void => {
    setIsOpen((prevIsOpen) => {
      const newIsOpen = [false, false];
      newIsOpen[index] = !prevIsOpen[index];
      return newIsOpen;
    });
  };

  const buildLink = ({ active, label, href }: NavigationLink, key = 0) => <a href={href} key={key} className={ active && 'usa-current' || '' }>{label}</a>;
  const items = navigationLinks.slice(0, 3).map(buildLink);
  const secondary = navigationLinks.slice(3).map(buildLink);

  if (secondary.length > 0) {
    items.push(
      <>
        <NavDropDownButton
          data-testid="moreBtn"
          menuId="moreDropDown"
          onToggle={onToggle(0, setIsOpen)}
          isOpen={isOpen[0]}
          label="More"
          isCurrent={false}
        />
        <Menu
          key="one"
          items={secondary}
          isOpen={isOpen[0]}
          id="moreMenuDropDown"
        />
      </>
    );
  }

  if (relatedSites.length > 0) {
    items.push(
      <>
        <NavDropDownButton
          data-testid="relatedSitesBtn"
          menuId="relatedSitesDropDown"
          onToggle={onToggle(1, setIsOpen)}
          isOpen={isOpen[1]}
          label="Related Sites"
          isCurrent={false}
        />
        <Menu
          key="one"
          items={relatedSites.map((site, index) => <a href={site.link} key={index}>{site.label}</a>)}
          isOpen={isOpen[1]}
          id="relatedSitesDropDown"
        />
      </>
    );
  }

  return (
    <div className="vertical-nav-wrapper">
      <GridContainer>
        <Header basic={true} className="vertical-wrapper">
          <div className="usa-nav-container">
            <PrimaryNav items={items} />
          </div>
        </Header>
      </GridContainer>
    </div>
  );
};
