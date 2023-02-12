import React, { useState, useEffect } from 'react';
import { Footer as UswdsFooter, GridContainer, FooterNav, Logo, Address } from '@trussworks/react-uswds';

import logoImg from 'uswds/src/img/logo-img.png';

interface FooterProps {
}

export const Footer = (props: FooterProps) => {

  const returnToTop = (
    <GridContainer className="usa-footer__return-to-top">
      <a href="#">Return to top</a>
    </GridContainer>
  )

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
                links={Array(4).fill(
                  <a className="usa-footer__primary-link" href="#">
                    Primary Link
                  </a>
                )}
              />
            </div>
            <div className="tablet:grid-col-4">
              <Address
                size="slim"
                items={[
                  <a key="telephone" href="tel:1-800-555-5555">
                    (800) CALL-GOVT
                  </a>,
                  <a key="email" href="mailto:info@agency.gov">
                    info@agency.gov
                  </a>,
                ]}
              />
            </div>
          </div>
        }
        secondary={
          <Logo
            size="slim"
            image={
              <img
                className="usa-footer__logo-img"
                alt="img alt text"
                src={logoImg}
              />
            }
            heading={<p className="usa-footer__logo-heading">Name of Agency</p>}
          />
        }
      />
    </div>
  );
}
