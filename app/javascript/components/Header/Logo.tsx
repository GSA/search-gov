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

  h1.usa-logo__text {
    font-size: inherit;
    line-height: inherit;
  }
`;

export const Logo = ({ page }: LogoProps) => {
  const styles = useContext(StyleContext);
  const hasImage = Boolean(page.logo?.url);
  const imageContent = hasImage ?
    <h1 className='margin-0'>
      <Link className='logo-link' href={page.homepageUrl}>
        <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title} />
      </Link>
    </h1> :
    null;
  const titleInner = page.homepageUrl ?
    <Link className='logo-link' href={page.homepageUrl}>{page.title}</Link> :
    page.title;
  const titleContent = page.displayLogoOnly ?
    <></> :
    hasImage ?
      <Title>{titleInner}</Title> :
      <div className="usa-logo">
        <h1 className="usa-logo__text">{titleInner}</h1>
      </div>;

  return <StyledLogo
    className="width-full"
    heading={titleContent}
    image={imageContent}
    size="slim"
    styles={styles}
  />;
};
