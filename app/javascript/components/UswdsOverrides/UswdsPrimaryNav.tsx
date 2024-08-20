import React from 'react';
import classnames from 'classnames';
import FocusTrap from 'focus-trap-react';
import { Options as FocusTrapOptions } from 'focus-trap';

import { NavCloseButton, NavList } from '@trussworks/react-uswds';

type PrimaryNavProps = {
  items: React.ReactNode[]
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
    // Return a promise that resolves when all the trap containers are able to receive focus
    return Promise.all(results);
  }
};

export const UswdsPrimaryNav = ({
  items,
  onToggleMobileNav,
  mobileExpanded,
  children,
  className,
  ...navProps
}: PrimaryNavProps & JSX.IntrinsicElements['nav']): React.ReactElement => {
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
        <NavCloseButton onClick={onToggleMobileNav} />
        <NavList items={items} type="primary" />
        {children}
      </nav>
    </FocusTrap>
  )
};
