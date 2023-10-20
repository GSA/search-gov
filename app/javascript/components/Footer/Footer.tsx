import React, { useContext } from 'react';
import { Footer as UswdsFooter, GridContainer, FooterNav, Address } from '@trussworks/react-uswds';
import { LanguageContext } from '../../contexts/LanguageContext';

import './Footer.css';

export const Footer = () => {
  const i18n = useContext(LanguageContext);

  const returnToTop = (
    <GridContainer className="usa-footer__return-to-top">
      <a href="#">
        {i18n.t('returnToTop')}
      </a>
    </GridContainer>
  );

  const primaryFooterLinks = [
    <a className="usa-footer__primary-link" href="#" key="primary-link-1">
      Primary Link 1
    </a>,
    <a className="usa-footer__primary-link" href="#" key="primary-link-2">
      Primary Link 2
    </a>,
    <a className="usa-footer__primary-link" href="#" key="primary-link-3">
      Primary Link 3
    </a>,
    <a className="usa-footer__primary-link" href="#" key="primary-link-4">
      Primary Link 4
    </a>
  ];

  const addressItems = [
    <a key="telephone" href="tel:1-800-555-5555">
      (800) CALL-GOVT
    </a>,
    <a key="email" href="mailto:info@agency.gov">
      info@agency.gov
    </a>
  ];

  return (
    <div id="serp-footer-wrapper">
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
            <div className="tablet:grid-col-4">
              <Address
                size="slim"
                items={addressItems}
              />
            </div>
          </div>
        }
        secondary={<></>}
      />
    </div>
  );
};
