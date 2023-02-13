import React, { useState, useEffect } from 'react';
import { Footer as UswdsFooter, GridContainer, FooterNav, Logo, Address } from '@trussworks/react-uswds';

//import logoImg from 'uswds/src/img/logo-img.png';
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
                src="https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg"
              />
            }
            heading={<p className="usa-footer__logo-heading">Name of Agency</p>}
          />
        }
      />
    </div>
  );
}
