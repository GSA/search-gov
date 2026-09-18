import '@testing-library/jest-dom';
import { render } from '@testing-library/react';
import React from 'react';

import { Footer } from '../components/Footer/Footer';

jest.mock('i18n-js', () => {
  return jest.requireActual('i18n-js/dist/require/index');
});

const footerLinks = [
  { title: 'first footer link', url: 'https://first.gov' },
  { title: 'second footer link', url: 'https://second.gov' }
];

describe('Footer', () => {
  it('uses declared footerLinks', () => {
    render(<Footer footerLinks={footerLinks} />);

    const [firstLink, secondLink] = Array.from(document.getElementsByClassName('usa-footer__primary-link'));
    expect(firstLink).toHaveAttribute('href', 'https://first.gov');
    expect(firstLink).toHaveTextContent('first footer link');

    expect(secondLink).toHaveAttribute('href', 'https://second.gov');
    expect(secondLink).toHaveTextContent('second footer link');
  });

  it('always shows Return to top and footer links when present', () => {
    render(<Footer footerLinks={footerLinks} />);

    expect(document.querySelector('.usa-footer__return-to-top')).toBeInTheDocument();
    expect(document.querySelector('.usa-footer__primary-section')).toBeInTheDocument();
    expect(document.querySelector('.usa-footer__primary-link')).toBeInTheDocument();
  });

  it('shows Return to top and no footer links when footer links are blank', () => {
    render(<Footer footerLinks={[]} />);

    expect(document.querySelector('.usa-footer__return-to-top')).toBeInTheDocument();
    expect(document.getElementsByClassName('usa-footer__primary-link')).toHaveLength(0);
    expect(document.querySelector('.usa-footer__nav')).not.toBeInTheDocument();
    expect(document.querySelector('.usa-footer__primary-section')).toBeEmptyDOMElement();
  });
});
