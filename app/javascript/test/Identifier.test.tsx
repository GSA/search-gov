import '@testing-library/jest-dom';
import { render, screen, within } from '@testing-library/react';
import { I18n } from 'i18n-js';
import React from 'react';

import { Identifier } from '../components/Identifier/Identifier';
import { LanguageContext } from '../contexts/LanguageContext';

const identifierContent = { 
  domainName: 'example domain name',
  parentAgencyName: 'My Agency',
  parentAgencyLink: 'https://agency.gov',
  logoUrl: 'https://www.search.gov/logo.png',
  logoAltText: 'identifier alt text',
  lookingForGovernmentServices: true
};

const identifierContentWithoutGovServices = { 
  domainName: 'example domain name',
  parentAgencyName: 'My Agency',
  parentAgencyLink: 'https://agency.gov',
  logoUrl: 'https://www.search.gov/logo.png',
  logoAltText: 'identifier alt text',
  lookingForGovernmentServices: false
};

const identifierLinks = [
  { title: 'first footer link', url: 'https://first.gov' },
  { title: 'second footer link', url: 'https://second.gov' }
];

const locale = {
  en: {
    lookingForUsGovInfo: 'Looking for U.S. Government information and services?',
    lookingForVoterRegInfo: 'Looking for voter registration information?',
    visitVoteDotGov: 'Visit Vote.gov'
  }
};

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const i18n = new I18n(locale);

describe('Identifier', () => {
  it('uses declared domainName', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={false} />);

    const [identifierDomainName] = Array.from(document.getElementsByClassName('usa-identifier__identity-domain'));
    expect(identifierDomainName).toHaveTextContent('example domain name');
  });

  it('uses declared parentAgencyName and parentAgencyLink', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={false} />);

    const identityDisclaimer = Array.from(document.getElementsByClassName('usa-identifier__identity-disclaimer')).pop() as HTMLParagraphElement;
    expect(identityDisclaimer).toHaveTextContent('My Agency');
    expect(within(identityDisclaimer).getByRole('link')).toHaveAttribute('href', 'https://agency.gov');
  });

  it('uses declared identifierLinks', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={false} />);

    const linksArray = Array.from(document.getElementsByClassName('usa-identifier__required-link'));
    const [firstLink, secondLink] = linksArray.slice(linksArray.length - 2);
    expect(firstLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstLink).toHaveTextContent('first footer link');

    expect(secondLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondLink).toHaveTextContent('second footer link');
  });

  it('has a logo with alt text', () => {
    render(<Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={false} />);

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo-img')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', 'https://www.search.gov/logo.png');
    expect(img).toHaveAttribute('alt', 'identifier alt text');
  });

  it('has a link for more US Government services', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={false} />
      </LanguageContext.Provider>
    );

    const identityGovContent = Array.from(document.getElementsByClassName('usa-identifier__usagov-description')).pop() as HTMLParagraphElement;
    expect(identityGovContent).toHaveTextContent('Looking for U.S. Government information and services?');
    const UsaLink = Array.from(document.getElementsByClassName('usa-link')).pop();
    expect(UsaLink).toHaveAttribute('href', 'https://www.usa.gov/');
  });

  it('does not have a link for more US Government services when the link is disabled', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Identifier identifierContent={identifierContentWithoutGovServices} identifierLinks={identifierLinks} showVoteOrgLink={false} />
      </LanguageContext.Provider>
    );

    const identifier = document.getElementById('serp-identifier-wrapper');
    expect(identifier).not.toHaveTextContent('Looking for U.S. Government information and services?');
  });

  it('has a link for vote.gov', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Identifier identifierContent={identifierContent} identifierLinks={identifierLinks} showVoteOrgLink={true} />
      </LanguageContext.Provider>
    );
    expect(screen.getByText('Looking for voter registration information?')).toBeInTheDocument();
    expect(screen.getByText('Visit Vote.gov')).toBeInTheDocument();
  });
});
