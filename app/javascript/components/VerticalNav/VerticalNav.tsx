import React, { useState } from 'react';
import { GridContainer, Header, NavDropDownButton, Menu, PrimaryNav } from '@trussworks/react-uswds';

import './VerticalNav.css';

interface VerticalNavProps {
  relatedSites?: {label: string, link: string}[];
}

export const VerticalNav = ({ relatedSites = [] }: VerticalNavProps) => {
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

  const moreMenuItems = [
    <a href="#linkOne" key="linkOne">
      Link 1
    </a>,
    <a href="#linkTwo" key="linkTwo">
      Link 2
    </a>
  ];

  const verticalLinkItems = [
    <a href="#one" key="one" className="usa-nav__link">
      <span>Link 1</span>
    </a>,
    <a href="#two" key="two" className="usa-nav__link">
      <span>Link 2</span>
    </a>,
    <a href="#two" key="two" className="usa-nav__link">
      <span>Link 3</span>
    </a>,
    <>
      <NavDropDownButton
        data-testid="moreBtn"
        menuId="moreDropDown"
        onToggle={(): void => {
          onToggle(0, setIsOpen);
        }}
        isOpen={isOpen[0]}
        label="More"
        isCurrent={false}
      />
      <Menu
        key="one"
        items={moreMenuItems}
        isOpen={isOpen[0]}
        id="moreMenuDropDown"
      />
    </>,
    <>
      <NavDropDownButton
        data-testid="relatedSitesBtn"
        menuId="relatedSitesDropDown"
        onToggle={(): void => {
          onToggle(1, setIsOpen);
        }}
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
  ];

  return (
    <div className="vertical-nav-wrapper">
      <GridContainer>
        <Header basic={true} className="vertical-wrapper">
          <div className="usa-nav-container">
            <PrimaryNav
              items={verticalLinkItems}
            />
          </div>
        </Header>
      </GridContainer>
    </div>
  );
};
