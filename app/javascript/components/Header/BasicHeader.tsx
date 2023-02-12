import React from 'react';
import { Header as UswdsHeader, PrimaryNav, Search, Title, NavMenuButton, NavDropDownButton, Menu } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

export const BasicHeader = (props: HeaderProps) => {
  
  const primaryNavItems = [
    <React.Fragment key="primaryNav_0">
      <NavDropDownButton
        menuId="extended-nav-section-one"
        isOpen={props.navDropdownOpen[0]}
        label={'<Current section>'}
        onToggle={(): void => {
          props.handleToggleNavDropdown(0)
        }}
        isCurrent
      />
      <Menu
        id="extended-nav-section-one"
        items={new Array(8).fill(
          <a href="">{'<Navigation link>'}</a>
        )}
        isOpen={props.navDropdownOpen[0]}
      />
    </React.Fragment>,
    <React.Fragment key="primaryNav_1">
      <NavDropDownButton
        menuId="extended-nav-section-two"
        isOpen={props.navDropdownOpen[1]}
        label={'<Section>'}
        onToggle={(): void => {
          props.handleToggleNavDropdown(1)
        }}
      />
      <Menu
        id="extended-nav-section-two"
        items={new Array(3).fill(
          <a href="">
            {'< A very long navigation link that goes on two lines>'}
          </a>
        )}
        isOpen={props.navDropdownOpen[1]}
      />
    </React.Fragment>,
    <a key="primaryNav_2" className="usa-nav__link" href="">
      <span>{'<Simple link>'}</span>
    </a>,
  ]

  return (
    <>
      <UswdsHeader basic>
        <div className="usa-nav-container">
          <div className="usa-navbar">
            <Title id="basic-logo">
              <a href="" title={props.title} aria-label={props.title}>
                {props.title}
              </a>
            </Title>
            <NavMenuButton
              label="Menu"
              onClick={props.toggleMobileNav}
              className="usa-menu-btn"
            />
          </div>
          <PrimaryNav
            aria-label="Primary navigation"
            items={primaryNavItems}
            onToggleMobileNav={props.toggleMobileNav}
            mobileExpanded={props.mobileNavOpen}>
            <Search size="small" onSubmit={props.handleSearch} />
          </PrimaryNav>
        </div>
      </UswdsHeader>
    </>
  );
}
