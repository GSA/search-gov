import React, { useState } from 'react';
import { GovBanner } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

import { BasicHeader } from './BasicHeader';
import { ExtendedHeader } from './ExtendedHeader';

interface HeaderProps {
  title: string;
  logoUrl: string;
  isBasic: boolean;
  fontsAndColors: {
    headerLinksFontFamily: string;
  };
}

export const Header = ({ title, logoUrl, isBasic, fontsAndColors }: HeaderProps) => {
  const [mobileNavOpen, setMobileNavOpen] = useState(false);

  const toggleMobileNav = (): void => {
    setMobileNavOpen((prevOpen) => !prevOpen);
  };

  const headerProps = {
    title,
    logoUrl,
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
