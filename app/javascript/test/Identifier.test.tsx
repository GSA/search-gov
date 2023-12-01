import '@testing-library/jest-dom';
import { render, within } from '@testing-library/react';
import React from 'react';

import { Identifier } from '../components/Identifier/Identifier';

const identifierContent = { 
  domainName: 'example domain name',
  parentAgencyName: 'My Agency',
  parentAgencyLink: 'https://agency.gov',
  logoUrl: 'https://www.search.gov/logo.png',
  logoAltText: 'identifier alt text'
};

const identifierLinks = [
  { title: 'first footer link', url: 'https://first.gov' },
  { title: 'second footer link', url: 'https://second.gov' }
];

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

describe('Identifier', () => {
  it('uses declared domainName', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} />);

    const [identifierDomainName] = Array.from(document.getElementsByClassName('usa-identifier__identity-domain'));
    expect(identifierDomainName).toHaveTextContent('example domain name');
  });

  it('uses declared parentAgencyName and parentAgencyLink', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} />);

    const identityDisclaimer = Array.from(document.getElementsByClassName('usa-identifier__identity-disclaimer')).pop() as HTMLParagraphElement;
    expect(identityDisclaimer).toHaveTextContent('My Agency');
    expect(within(identityDisclaimer).getByRole('link')).toHaveAttribute('href', 'https://agency.gov');
  });

  it('uses declared identifierLinks', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} />);

    const linksArray = Array.from(document.getElementsByClassName('usa-identifier__required-link'));
    const [firstLink, secondLink] = linksArray.slice(linksArray.length - 2);
    expect(firstLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstLink).toHaveTextContent('first footer link');

    expect(secondLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondLink).toHaveTextContent('second footer link');
  });

  it('has a logo with alt text', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} />);

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo-img')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', 'https://www.search.gov/logo.png');
    expect(img).toHaveAttribute('alt', 'identifier alt text');
  });
});
