import React, { useContext } from 'react';
import styled from 'styled-components';
import { Logo as UswdsLogo, Link, Title } from '@trussworks/react-uswds';

import { FontsAndColors, PageData } from '../SearchResultsLayout';
import { StyleContext } from '../../contexts/StyleContext';

interface LogoProps {
  page: PageData;
}

const StyledLogo = styled(UswdsLogo).attrs<{ styles: FontsAndColors; }>((props) => ({ styles: props.styles }))`
  color: ${(props) => props.styles.headerTextColor} !important;
`;

export const Logo = ({ page }: LogoProps) => {
  const styles = useContext(StyleContext);
  const imageContent = page.logo?.url ? 
    <h1 className='margin-0'>
      <Link className='logo-link' href={page.homepageUrl}>
        <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title}/>
      </Link>
    </h1> : 
    null;
  const titleContent =  (!page.displayLogoOnly) ? (page.homepageUrl) ? 
    <Title>
      <Link className='logo-link' href={page.homepageUrl}>{page.title}</Link>
    </Title> : 
    <Title>{page.title}</Title> : 
    <></>;

  return <StyledLogo
    className="width-full"
    heading={titleContent}
    image={imageContent}
    size="slim"
    styles={styles}
  />;
};
