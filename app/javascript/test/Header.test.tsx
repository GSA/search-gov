import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { I18n } from 'i18n-js';
import { Header } from '../components/Header';
import { LanguageContext } from '../contexts/LanguageContext';

jest.mock('i18n-js', () => jest.requireActual('i18n-js/dist/require/index'));

const locale = {
  en: {
    searches: { menu: 'Menu' },
    ariaLabelHeader: 'Primary navigation'
  }
};

const i18n = new I18n(locale);

describe('Header', () => {
  const page = {
    affiliate: 'searchgov',
    displayLogoOnly: false,
    title: 'Search.gov',
    logo: {
      url: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg',
      text: 'search.gov'
    },
    homepageUrl: 'https://search.gov',
    showVoteOrgLink: false
  };

  const primaryHeaderLinks = [
    { title: 'first primary header link', url: 'https://first.gov' },
    { title: 'second primary header link', url: 'https://second.gov' }
  ];

  const secondaryHeaderLinks = [
    { title: 'first secondary header link', url: 'https://first.gov' },
    { title: 'second secondary header link', url: 'https://second.gov' }
  ];

  it('shows agency title and links in the basic header', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Header page={page} isBasic={true} primaryHeaderLinks={primaryHeaderLinks} secondaryHeaderLinks={secondaryHeaderLinks} />
      </LanguageContext.Provider>
    );
    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const [logoImg, logoText] = Array.from(document.getElementsByClassName('logo-link'));
    expect(logoImg).toHaveAttribute('href', 'https://search.gov');
    expect(logoText).toHaveAttribute('href', 'https://search.gov');

    const [firstPrimaryHeaderLink, secondPrimaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__link'));
    expect(firstPrimaryHeaderLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstPrimaryHeaderLink).toHaveTextContent('first primary header link');

    expect(secondPrimaryHeaderLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondPrimaryHeaderLink).toHaveTextContent('second primary header link');

    // To Do - investigate test cases for responsive
    const btn = screen.getByTestId('usa-menu-mob-btn'); // Menu button for mobile
    fireEvent.click(btn);
    expect(firstPrimaryHeaderLink).toBeInTheDocument();
  });

  it('shows agency title and links in the extended header', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Header page={page} isBasic={false} primaryHeaderLinks={primaryHeaderLinks} secondaryHeaderLinks={secondaryHeaderLinks} />
      </LanguageContext.Provider>
    );

    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const [logoImg, logoText] = Array.from(document.getElementsByClassName('logo-link'));
    expect(logoImg).toHaveAttribute('href', 'https://search.gov');
    expect(logoText).toHaveAttribute('href', 'https://search.gov');

    const [firstPrimaryHeaderLink, secondPrimaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__link'));
    expect(firstPrimaryHeaderLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstPrimaryHeaderLink).toHaveTextContent('first primary header link');

    expect(secondPrimaryHeaderLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondPrimaryHeaderLink).toHaveTextContent('second primary header link');

    const [firstSecondaryHeaderLink, secondSecondaryHeaderLink] = Array.from(document.getElementsByClassName('usa-nav__secondary-item'));
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://first.gov');
    expect(firstSecondaryHeaderLink.childNodes[0]).toHaveTextContent('first secondary header link');

    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveAttribute('href', 'https://second.gov');
    expect(secondSecondaryHeaderLink.childNodes[0]).toHaveTextContent('second secondary header link');
  });

  it('shows agency logo and alt text in the basic header', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Header page={page} isBasic={true} />
      </LanguageContext.Provider>
    );

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', page.logo.url);
    expect(img).toHaveAttribute('alt', page.logo.text);
  });

  it('shows agency logo and alt text in the basic header', () => {
    render(
      <LanguageContext.Provider value={i18n} >
        <Header page={page} isBasic={false} />
      </LanguageContext.Provider>
    );

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', page.logo.url);
    expect(img).toHaveAttribute('alt', page.logo.text);
  });
});
