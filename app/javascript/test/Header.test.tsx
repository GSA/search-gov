import '@testing-library/jest-dom';
import { render, screen, fireEvent } from '@testing-library/react';
import React from 'react';
import { Header } from '../components/Header';

describe('Header', () => {
  const page = {
    title: 'Search.gov',
    logo: {
      url: 'https://search.gov/assets/gsa-logo-893b811a49f74b06b2bddbd1cde232d2922349c8c8c6aad1d88594f3e8fe42bd097e980c57c5e28eff4d3a9256adb4fcd88bf73a5112833b2efe2e56791aad9d.svg',
      text: 'search.gov'
    }
  };

  it('shows agency title and links in the basic header', () => {
    render(<Header page={page} isBasic={true} />);
    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toBeInTheDocument();

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toBeInTheDocument();

    // To Do - investigate test cases for responsive
    const btn = screen.getByTestId('usa-menu-mob-btn'); // Menu button for mobile
    fireEvent.click(btn);
    expect(primaryLinkTitle).toBeInTheDocument();
  });

  it('shows agency title and links in the extended header', () => {
    render(<Header page={page} isBasic={false} />);

    const title = screen.getByText(/Search.gov/i);
    expect(title).toBeInTheDocument();

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toBeInTheDocument();

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toBeInTheDocument();
  });

  it('uses declared headerLinksFontFamily font', () => {
    render(<Header page={page} isBasic={false} fontsAndColors={fontsAndColors} />);

    const primaryLinkTitle = screen.getByText(/Primary link 1/i);
    expect(primaryLinkTitle).toHaveStyle({
      'font-family': '"Georgia", "Cambria", "Times New Roman", "Times", serif'
    });

    const secondaryLinkTitle = screen.getByText(/Secondary link 1/i);
    expect(secondaryLinkTitle).toHaveStyle({
      'font-family': '"Georgia", "Cambria", "Times New Roman", "Times", serif'
    });
  });

  it('shows agency logo and alt text in the basic header', () => {
    render(<Header page={page} isBasic={true} fontsAndColors={fontsAndColors} />);

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', page.logo.url);
    expect(img).toHaveAttribute('alt', page.logo.text);
  });

  it('shows agency logo and alt text in the basic header', () => {
    render(<Header page={page} isBasic={false} fontsAndColors={fontsAndColors} />);

    const img = Array.from(document.getElementsByClassName('usa-identifier__logo')).pop() as HTMLImageElement;

    expect(img).toHaveAttribute('src', page.logo.url);
    expect(img).toHaveAttribute('alt', page.logo.text);
  });
});
