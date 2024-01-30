import React from 'react';
import { Identifier as IdentifierLogos, IdentifierLogo } from '@trussworks/react-uswds';

interface IdentifierLogoWrapperProps {
  logoUrl: string;
  logoAltText?: string | null;
}

export const IdentifierLogoWrapper = ({ logoUrl, logoAltText }: IdentifierLogoWrapperProps) => {
  return (
    <div id="serp-identifier-logo-wrapper" className="margin-right-2">
      <IdentifierLogos>
        <IdentifierLogo href="">
          <img
            className="usa-identifier__logo-img"
            src={logoUrl}
            alt={logoAltText || ''}
          />
        </IdentifierLogo>
      </IdentifierLogos>
    </div>
  );
};
