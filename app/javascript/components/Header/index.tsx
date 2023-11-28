import React, { useState } from 'react';
import { GovBanner } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

import { BasicHeader } from './BasicHeader';
import { ExtendedHeader } from './ExtendedHeader';
import { PageData } from '../SearchResultsLayout';

interface HeaderProps {
  page: PageData;
  isBasic: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
}

export const Header = ({ page, isBasic, fontsAndColors }: HeaderProps) => {
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const toggleMobileNav = (): void => {
    setMobileNavOpen((prevOpen) => !prevOpen);
  };

  const headerProps = {
    page,
    toggleMobileNav,
    mobileNavOpen,
    fontsAndColors
  };
 
  return (
    <>
      <a className="usa-skipnav" href="#main-content">
        Skip to main content
      </a>
      <GovBanner />
      <div className={`usa-overlay ${mobileNavOpen ? 'is-visible' : ''}`}></div>

      {isBasic ? 
        <BasicHeader 
          {...headerProps}
        />:
        <ExtendedHeader 
          {...headerProps}
        />
      }
    </>
  );
};
