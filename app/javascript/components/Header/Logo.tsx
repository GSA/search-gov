import React from 'react';
import { Logo as UswdsLogo, Link, Title } from '@trussworks/react-uswds';

import { PageData } from '../SearchResultsLayout';

interface LogoProps {
  page: PageData;
}

export const Logo = ({ page }: LogoProps) => {
  const imageContent = page.logo?.url ? 
    <Link className='logo-link' href={page.homepageUrl}>
      <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title}/>
    </Link> : 
    null;
  const titleContent = page.displayLogoOnly ? 
    <></> : 
    <Title>
      <Link className='logo-link' href={page.homepageUrl}>{page.title}</Link>
    </Title>
    ;

  return (
    <UswdsLogo
      className="width-full"
      size="slim"
      image={imageContent}
      heading={titleContent}
    />
  );
};
