import React, { useContext } from 'react';
import styled from 'styled-components';
import { Identifier as UswdsIdentifier, IdentifierMasthead, IdentifierLinks, IdentifierIdentity, Link, IdentifierGov, IdentifierLinkItem, IdentifierLink } from '@trussworks/react-uswds';
import { LanguageContext } from '../../contexts/LanguageContext';
import { StyleContext } from '../../contexts/StyleContext';
import { FontsAndColors } from '../SearchResultsLayout';

import { IdentifierLogoWrapper } from './IdentifierLogoWrapper';

interface IdentifierProps {
  identifierContent?: {
    domainName: string | null;
    parentAgencyName: string | null;
    parentAgencyLink: string | null;
    logoUrl: string | null;
    logoAltText: string | null;
  };
  identifierLinks?: {
    title: string,
    url: string
  }[] | null;
}

const StyledUswdsIdentifier = styled(UswdsIdentifier).attrs<{ styles: FontsAndColors; }>((props) => ({
  styles: props.styles
}))`
  background-color: ${(props) => props.styles.identifierBackgroundColor};
  font-family: ${(props) => props.styles.identifierFontFamily} !important;

  .usa-identifier__container, .usa-identifier__container > a, .usa-identifier__identity-disclaimer, .usa-identifier__identity-disclaimer > a {
    color: ${(props) => props.styles.identifierHeadingColor};
  }
  .usa-identifier__required-links-item > a, .usa-identifier__identity-domain {
    color: ${(props) => props.styles.identifierLinkColor};
  }
`;

export const Identifier = ({ identifierContent, identifierLinks }: IdentifierProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);

  const primaryIdentifierContent = (identifierContent?.parentAgencyLink && identifierContent?.parentAgencyName) ?
    <>
      {i18n.t('officialWebsiteOf')}{' '}
      <Link href={identifierContent.parentAgencyLink}>
        {identifierContent.parentAgencyName}
      </Link>
    </> : <></>;

  const primaryIdentifierLinks = identifierLinks ? 
    <>
      {identifierLinks.map((link, index) => {
        return (
          <IdentifierLinkItem key={index}>
            <IdentifierLink href={link.url}>{link.title}</IdentifierLink>
          </IdentifierLinkItem>
        );
      })}
    </> : <></>;

  return (
    <StyledUswdsIdentifier styles={styles}>
      <div id="serp-identifier-wrapper">
        <IdentifierMasthead aria-label="Agency identifier">
          {identifierContent?.logoUrl && (
            <IdentifierLogoWrapper
              logoUrl={identifierContent.logoUrl}
              logoAltText={identifierContent?.logoAltText}
            />
          )}
          <IdentifierIdentity domain={identifierContent?.domainName || ''}>
            {primaryIdentifierContent}
          </IdentifierIdentity>
        </IdentifierMasthead>
        <IdentifierLinks navProps={{ 'aria-label': 'Important links' }}>
          {primaryIdentifierLinks}
        </IdentifierLinks>
        <IdentifierGov aria-label="U.S. government information and services">
          <div className="usa-identifier__usagov-description">
            {i18n.t('lookingForUsGovInfo')}
          </div>
          &nbsp;
          <Link href="https://www.usa.gov/" className="usa-link">
            {i18n.t('visitUsaDotGov')}
          </Link>
        </IdentifierGov>
      </div>
    </StyledUswdsIdentifier>
  );
};
