import React from 'react';
import { Logo as UswdsLogo, Title } from '@trussworks/react-uswds';

import { PageData } from '../SearchResultsLayout';

interface LogoProps {
  page: PageData;
}

export const Logo = ({ page }: LogoProps) => (
  <UswdsLogo
    className="width-full"
    size="slim"
    image={page.logo?.url ? <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title} /> : null}
    heading={page.displayLogoOnly ? <></> : <Title>{page.title}</Title>}
  />
);
