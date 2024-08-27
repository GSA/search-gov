import React, { useContext } from 'react';
import styled from 'styled-components';
import { Footer as UswdsFooter, GridContainer, FooterNav } from '@trussworks/react-uswds';
import { LanguageContext } from '../../contexts/LanguageContext';
import { StyleContext } from '../../contexts/StyleContext';

import './Footer.css';

interface FooterProps {
  footerLinks?: {
    title: string,
    url: string
  }[];
}

const StyledUswdsFooter = styled.div.attrs<{ styles: { footerAndResultsFontFamily: string, footerBackgroundColor: string, footerLinksTextColor: string; pageBackgroundColor: string }; }>((props) => ({
  styles: props.styles
}))`
  font-family: ${(props) => props.styles.footerAndResultsFontFamily};
  background-color: ${(props) => props.styles.pageBackgroundColor};
  .usa-footer__return-to-top > a, a.usa-footer__primary-link {
    color: ${(props) => props.styles.footerLinksTextColor};
  }
  .usa-footer .usa-footer__primary-section {
    background-color: ${(props) => props.styles.footerBackgroundColor};
  }
`;

export const Footer = ({ footerLinks = [] }: FooterProps) => {
  const i18n = useContext(LanguageContext);
  const styles = useContext(StyleContext);

  const returnToTop = (
    <GridContainer className="usa-footer__return-to-top">
      <a href="#main-content" aria-labelledby={i18n.t('returnToTop')}>
        {i18n.t('returnToTop')}
      </a>
    </GridContainer>
  );

  const primaryFooterLinks =
    footerLinks && footerLinks.length > 0 ? (footerLinks.map((link, index) => {
      return (
        <a className="usa-footer__primary-link" href={link.url} key={index}>
          {link.title}
        </a>
      );
    })) : (
      [
        <></>
      ]
    );

  return (
    <div id="serp-footer-wrapper">
      <StyledUswdsFooter styles={styles}>
        <UswdsFooter 
          size="slim"
          returnToTop={returnToTop}
          primary={
            <div className="usa-footer__primary-container grid-row">
              <div className="mobile-lg:grid-col-8">
                <FooterNav
                  size="slim"
                  links={primaryFooterLinks}
                />
              </div>
            </div>
          }
          secondary={<></>}
        />
      </StyledUswdsFooter>
    </div>
  );
};
