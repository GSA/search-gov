import React, { useContext } from 'react';
import { Identifier as UswdsIdentifier, IdentifierMasthead, IdentifierLinks, IdentifierLogos, IdentifierLogo, IdentifierIdentity, Link, IdentifierGov, IdentifierLinkItem, IdentifierLink } from '@trussworks/react-uswds';
import { LanguageContext } from '../../contexts/LanguageContext';

// this is just a dummy logo for UI purposes - to be dynamic
const logoImg = 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg';

export const Identifier = () => {
  const i18n = useContext(LanguageContext);

  const identifierLinksText = [
    'About <Parent shortname>',
    'Accessibility support',
    'FOIA requests',
    'No FEAR Act data',
    'Office of the Inspector General',
    'Performance reports',
    'Privacy policy'
  ];

  return (
    <div id="serp-identifier-wrapper">
      <UswdsIdentifier>
        <IdentifierMasthead aria-label="Agency identifier">
          <IdentifierLogos>
            <IdentifierLogo href="">
              <img
                className="usa-identifier__logo-img"
                src={logoImg}
                alt="<Parent agency> logo"
              />
            </IdentifierLogo>
          </IdentifierLogos>
          <IdentifierIdentity domain={'<domain.gov>'}>
            {i18n.t('official_website_of')}
            <Link href="">Parent agency</Link>
          </IdentifierIdentity>
        </IdentifierMasthead>
        <IdentifierLinks navProps={{ 'aria-label': 'Important links' }}>
          {identifierLinksText.map((text, idx) => (
            <IdentifierLinkItem key={idx}>
              <IdentifierLink href="">{text}</IdentifierLink>
            </IdentifierLinkItem>
          ))}
        </IdentifierLinks>
        <IdentifierGov aria-label="U.S. government information and services">
          <div className="usa-identifier__usagov-description">
            {i18n.t('lookingForUsGovInfo')}
          </div>
          &nbsp;
          <Link href="" className="usa-link">
            {i18n.t('visitUsaDotGov')}
          </Link>
        </IdentifierGov>
      </UswdsIdentifier>
    </div>
  );
};
