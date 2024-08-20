import React from 'react';
import classnames from 'classnames';
import FocusTrap from 'focus-trap-react';

import { NavCloseButton } from '@trussworks/react-uswds';
import { NavList } from '@trussworks/react-uswds';

type ExtendedNavProps = {
  primaryItems: React.ReactNode[]
  secondaryItems: React.ReactNode[]
  onToggleMobileNav?: (
    event: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => void
  mobileExpanded?: boolean
}

const focusTrapOptions = {
  checkCanFocusTrap: (trapContainers) => {
    const results = trapContainers.map((trapContainer) => {
      return new Promise((resolve) => {
        const interval = setInterval(() => {
          if (getComputedStyle(trapContainer).visibility !== 'hidden') {
            resolve();
            clearInterval(interval);
          }
        }, 5);
      });
    });
    // Return a promise that resolves when all the trap containers are able to receive focus
    return Promise.all(results);
  }
};

export const UswdsExtendedNav = ({
  primaryItems,
  secondaryItems,
  mobileExpanded = false,
  children,
  className,
  onToggleMobileNav,
  ...navProps
}: ExtendedNavProps & JSX.IntrinsicElements['nav']): React.ReactElement => {
  const classes = classnames(
    'usa-nav',
    {
      'is-visible': mobileExpanded,
    },
    className
  )

  return (
    <FocusTrap active={mobileExpanded} focusTrapOptions={focusTrapOptions}>
      <nav className={classes} {...navProps}>
        <div className="usa-nav__inner">
          <NavCloseButton onClick={onToggleMobileNav} />
          <NavList items={primaryItems} type="primary" />
          <div className="usa-nav__secondary">
            <NavList items={secondaryItems} type="secondary" />
            {children}
          </div>
        </div>
      </nav>
    </FocusTrap>
  )
}

export default UswdsExtendedNav;
