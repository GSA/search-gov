import React, { useState, useEffect } from 'react';
import { Identifier as UswdsIdentifier, IdentifierMasthead, IdentifierLinks, IdentifierLogos, IdentifierLogo, IdentifierIdentity, Link, IdentifierGov, IdentifierLinkItem, IdentifierLink } from '@trussworks/react-uswds';

//import circleSvg from 'uswds/src/img/circle-gray-20.svg';
interface IdentifierProps {
}

export const Identifier = (props: IdentifierProps) => {

  const identifierLinksText = [
    'About <Parent shortname>',
    'Accessibility support',
    'FOIA requests',
    'No FEAR Act data',
    'Office of the Inspector General',
    'Performance reports',
    'Privacy policy',
  ]

  return (
    <div id="serp-identifier-wrapper">
      <UswdsIdentifier>
        <IdentifierMasthead aria-label="Agency identifier">
          <IdentifierLogos>
            <IdentifierLogo href="">
              <img
                className="usa-identifier__logo-img"
                src=""
                //src={circleSvg}
                alt="<Parent agency> logo"
              />
            </IdentifierLogo>
          </IdentifierLogos>
          <IdentifierIdentity domain={'<domain.gov>'}>
            An official website of the{' '}
            <Link href="">{`<Parent agency>`}</Link>
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
            Looking for U.S. government information and services?
          </div>
          &nbsp;
          <Link href="" className="usa-link">
            Visit USA.gov
          </Link>
        </IdentifierGov>
      </UswdsIdentifier>
    </div>
  );
}
