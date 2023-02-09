import * as React from 'react';
import { GovBanner, Header as UswdsHeader, Title, NavMenuButton, ExtendedNav, NavDropDownButton, Menu } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

interface HeaderProps {
  title: string
}

const testMenuItems = [
  <a href="#" key="one">
    Privacy policy
  </a>,
  <a href="#" key="two">
    Latest updates
  </a>,
];

const testItemsMenu = [
  <>
    <NavDropDownButton
      onToggle={() => {}}
      menuId="testDropDownOne"
      isOpen={false}
      label="Section"
      isCurrent={true}
    />
    <Menu
      key="one"
      items={testMenuItems}
      isOpen={false}
      id="testDropDownOne"
    />
  </>,
  <a href="#two" key="two" className="usa-nav__link">
    <span>Link</span>
  </a>,
  <a href="#three" key="three" className="usa-nav__link">
    <span>Link</span>
  </a>,
];

export const Header = (props: HeaderProps) => {
  return (
    <div id="serp-header-wrapper">
      <GovBanner aria-label="Official government website" />
      <UswdsHeader extended={true}>
        <div className="usa-navbar">
          <Title>{props.title}</Title>
          <NavMenuButton onClick={() => {}} label="Menu" />
        </div>
        <ExtendedNav
          primaryItems={testItemsMenu}
          secondaryItems={testMenuItems}
          mobileExpanded={false}
          onToggleMobileNav={() => {}}>
        </ExtendedNav>
      </UswdsHeader>
    </div>
  );
}
