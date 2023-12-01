import React from 'react';
import { Identifier as IdentifierLogos, IdentifierLogo } from '@trussworks/react-uswds';

interface IdentifierLogoWrapperProps {
  logoUrl: string | null;
  logoAltText?: string | null;
}

const logoImg = 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg';

export const IdentifierLogoWrapper = ({ logoUrl, logoAltText }: IdentifierLogoWrapperProps) => {
  return (
    <div id="serp-identifier-logo-wrapper">
      <IdentifierLogos>
        <IdentifierLogo href="">
          <img
            className="usa-identifier__logo-img"
            src={logoUrl || logoImg}
            alt={logoAltText || ''}
          />
        </IdentifierLogo>
      </IdentifierLogos>
    </div>
  );
};
