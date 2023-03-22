import React, { useState } from 'react';
import { GridContainer, Header, NavDropDownButton, Menu, PrimaryNav } from '@trussworks/react-uswds';

import './VerticalNav.css';

export const VerticalNav = () => {
  const [isOpen, setIsOpen] = useState([false, false]);
  const [isOpen2, setIsOpen2] = useState([false, false]);

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

  const relatedSitesItems = [
    <a href="#relatedSitesItem1" key="relatedSitesItem1">
      Related Site 1
    </a>,
    <a href="#relatedSitesItem2" key="relatedSitesItem2">
      Related Site 2
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
          onToggle(0, setIsOpen2);
        }}
        isOpen={isOpen2[0]}
        label="Related Sites"
        isCurrent={false}
      />
      <Menu
        key="one"
        items={relatedSitesItems}
        isOpen={isOpen2[0]}
        id="relatedSitesDropDown"
      />
    </>
  ];

  return (
    <div id="vertical-nav-wrapper">
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
