import React from 'react';
import { Header as UswdsHeader, PrimaryNav, Search, Title, NavMenuButton, NavDropDownButton, Menu } from '@trussworks/react-uswds';

import { HeaderProps } from './../props';

export const BasicHeader = (props: HeaderProps) => {
  
  const primaryNavItems = [
    <React.Fragment key="primaryNav_0">
      <NavDropDownButton
        data-testid="current-section"
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
        items={[
          <a href="">{'<Navigation link 1>'}</a>,
          <a href="">{'<Navigation link 2>'}</a>,
          <a href="">{'<Navigation link 3>'}</a>,
          <a href="">{'<Navigation link 4>'}</a>
        ]}
        isOpen={props.navDropdownOpen[0]}
      />
    </React.Fragment>,
    <React.Fragment key="primaryNav_1">
      <NavDropDownButton
        data-testid="current-section-2"
        menuId="extended-nav-section-two"
        isOpen={props.navDropdownOpen[1]}
        label={'<Section>'}
        onToggle={(): void => {
          props.handleToggleNavDropdown(1)
        }}
      />
      <Menu
        id="extended-nav-section-two"
        items={[
          <a href="">
            {'<Section link 1>'}
          </a>,
          <a href="">
            {'<Section link 2>'}
          </a>
        ]}
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
              data-testid="usa-menu-mob-btn"
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
