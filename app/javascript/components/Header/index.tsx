import React, { useState, useEffect } from 'react';
import { GovBanner } from '@trussworks/react-uswds';

import '@trussworks/react-uswds/lib/uswds.css';
import '@trussworks/react-uswds/lib/index.css';

import { BasicHeader } from './BasicHeader';
import { ExtendedHeader } from './ExtendedHeader';
interface HeaderProps {
  title: string
  isBasic: boolean
}

export const Header = (props: HeaderProps) => {
  const [mobileNavOpen, setMobileNavOpen] = useState(false);
  const [navDropdownOpen, setNavDropdownOpen] = useState([false, false]);

  const toggleMobileNav = (): void => {
    setMobileNavOpen((prevOpen) => !prevOpen)
  }

  const handleToggleNavDropdown = (index: number): void => {
    setNavDropdownOpen((prevNavDropdownOpen) => {
      const newOpenState = Array(prevNavDropdownOpen.length).fill(false)
      
      newOpenState[index] = !prevNavDropdownOpen[index]
      return newOpenState
    })
  }

  const handleSearch = (event): void => {
    console.log("clicked");
    event.preventDefault();
  }
 
  return (
    <>
      <a className="usa-skipnav" href="#main-content">
        Skip to main content
      </a>
      <GovBanner />
      <div className={`usa-overlay ${mobileNavOpen ? 'is-visible' : ''}`}></div>

      {props.isBasic ? 
      <BasicHeader 
        title={props.title}
        handleSearch={handleSearch}
        toggleMobileNav={toggleMobileNav}
        mobileNavOpen={mobileNavOpen}
        handleToggleNavDropdown={handleToggleNavDropdown}
        navDropdownOpen= {navDropdownOpen}
      />:
      <ExtendedHeader 
        title={props.title}
        handleSearch={handleSearch}
        toggleMobileNav={toggleMobileNav}
        mobileNavOpen={mobileNavOpen}
        handleToggleNavDropdown={handleToggleNavDropdown}
        navDropdownOpen= {navDropdownOpen}
      />}
    </>
  );
}
