import React, { useContext } from 'react';
import styled from 'styled-components';
import { Identifier as UswdsIdentifier, IdentifierMasthead, IdentifierLinks, IdentifierLogos, IdentifierLogo, IdentifierIdentity, Link, IdentifierGov, IdentifierLinkItem, IdentifierLink } from '@trussworks/react-uswds';
import { LanguageContext } from '../../contexts/LanguageContext';
import { StyleContext } from '../../contexts/StyleContext';

interface IdentifierProps {
  identifierContent?: {
    domainName: string | null;
    parentAgencyName: string | null;
    parentAgencyLink: string | null;
  };
  identifierLinks?: {
    title: string,
    url: string
  }[] | null;
}

const StyledUswdsIdentifier = styled(UswdsIdentifier).attrs<{ styles: { identifierBackgroundColor: string, identifierHeadingColor: string; identifierLinkColor: string; }; }>(props => ({
  styles: props.styles,
}))`
  background-color: ${props => props.styles.identifierBackgroundColor};
  .usa-identifier__container, .usa-identifier__container > a, .usa-identifier__identity-disclaimer, .usa-identifier__identity-disclaimer > a {
    color: ${props => props.styles.identifierHeadingColor};
  }
  .usa-identifier__required-links-item > a, .usa-identifier__identity-domain {
    color: ${props => props.styles.identifierLinkColor};
  }
`;

// this is just a dummy logo for UI purposes - to be dynamic
const logoImg = 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg';

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

  const primaryIdentifierLinks = identifierLinks && identifierLinks.length > 0 ? 
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
    <div id="serp-identifier-wrapper">
      <StyledUswdsIdentifier styles={styles}>
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
      </StyledUswdsIdentifier>
    </div>
  );
};
