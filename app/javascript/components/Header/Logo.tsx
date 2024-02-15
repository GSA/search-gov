import React, { useContext } from 'react';
import styled from 'styled-components';
import { Logo as UswdsLogo, Title } from '@trussworks/react-uswds';

import { PageData } from '../SearchResultsLayout';
import { FontsAndColors } from '../SearchResultsLayout';
import { StyleContext } from '../../contexts/StyleContext';

interface LogoProps {
  page: PageData;
}

const StyledLogo = styled(UswdsLogo).attrs<{ styles: FontsAndColors; }>((props) => ({ styles: props.styles }))`
  color: ${(props) => props.styles.headerTextColor} !important;
`;

export const Logo = ({ page }: LogoProps) => {
  const styles = useContext(StyleContext);

  return <StyledLogo
    className="width-full"
    heading={page.displayLogoOnly ? <></> : <Title>{page.title}</Title>}
    image={page.logo?.url ? <img className="usa-identifier__logo" src={page.logo.url} alt={page.logo.text || page.title} /> : null}
    size="slim"
    styles={styles}
  />
};
