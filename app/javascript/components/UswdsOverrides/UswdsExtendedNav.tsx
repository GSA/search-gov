import React from 'react';
import classnames from 'classnames';
import FocusTrap from 'focus-trap-react';

import { NavCloseButton, NavList } from '@trussworks/react-uswds';

type ExtendedNavProps = {
  primaryItems: React.ReactNode[]
  secondaryItems: React.ReactNode[]
  onToggleMobileNav?: (
    event: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => void
  mobileExpanded?: boolean
}

const focusTrapOptions: any = {
  checkCanFocusTrap: (trapContainers: any) => {
    const results = trapContainers.map((trapContainer: any) => {
      return new Promise<void>((resolve) => {
        const interval = setInterval(() => {
          if (getComputedStyle(trapContainer).visibility !== 'hidden') {
            resolve();
            clearInterval(interval);
          }
        }, 5);
      });
    });
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
};
