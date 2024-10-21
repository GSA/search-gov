/* USWDS override from https://github.com/trussworks/react-uswds/blob/main/src/components/header/PrimaryNav/PrimaryNav.tsx to implement focus trap */

import React from 'react';
import classnames from 'classnames';
import FocusTrap from 'focus-trap-react';
import { NavCloseButton, NavList } from '@trussworks/react-uswds';
import { focusTrapOptions } from '../../utils';

type PrimaryNavProps = {
  items: React.ReactNode[]
  onToggleMobileNav?: (
    event: React.MouseEvent<HTMLButtonElement, MouseEvent>
  ) => void
  mobileExpanded?: boolean
}

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
