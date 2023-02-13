import React from 'react';
import { Header as UswdsHeader, Search, Title, NavMenuButton, ExtendedNav, NavDropDownButton, Menu } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

export const ExtendedHeader = (props: HeaderProps) => {

  const testMenuItems = [
    <a href="#linkOne" key="one">
      Privacy policy
    </a>,
    <a href="#linkTwo" key="two">
      Latest updates
    </a>,
  ]

  const testItemsMenu = [
    <>
      <NavDropDownButton
        onToggle={(): void => {
          props.handleToggleNavDropdown(0)
        }}
        menuId="testDropDownOne"
        isOpen={props.navDropdownOpen[0]}
        label="Nav Label"
        isCurrent={true}
      />
      <Menu
        key="one"
        items={testMenuItems}
        isOpen={props.navDropdownOpen[0]}
        id="testDropDownOne"
      />
    </>,
    <a href="#two" key="two" className="usa-nav__link">
      <span>Parent link</span>
    </a>,
    <a href="#three" key="three" className="usa-nav__link">
      <span>Parent link</span>
    </a>,
  ]
  
  return (
    <>
      <UswdsHeader extended={true}>
        <div className="usa-navbar">
          <Title>{props.title}</Title>
          <NavMenuButton onClick={props.toggleMobileNav} label="Menu" />
        </div>
        <ExtendedNav
          primaryItems={testItemsMenu}
          secondaryItems={testMenuItems}
          mobileExpanded={props.mobileNavOpen}
          onToggleMobileNav={props.toggleMobileNav}>
          <Search size="small" onSubmit={props.handleSearch} />
        </ExtendedNav>
      </UswdsHeader>
    </>
  )
}
